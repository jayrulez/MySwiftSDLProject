import Foundation
import SedulousJobs
import Logging

// MARK: - Resource Protocol
public protocol Resource: AnyObject, Codable, Sendable {
    var id: UUID { get }
    var name: String { get set }
}

// MARK: - Base Resource Implementation
open class BaseResource: Resource, @unchecked Sendable {
    public let id: UUID
    public var name: String
    
    public init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
    
    // MARK: - Codable
    public enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

// MARK: - Resource Handle (Now just a wrapper that provides validation)
public struct ResourceHandle<T: Resource>: Sendable {
    private weak var resource: T?
    
    public var value: T? {
        return resource
    }
    
    public var isValid: Bool {
        return resource != nil
    }
    
    public init(_ resource: T?) {
        self.resource = resource
    }
    
    // No manual reference management needed - ARC handles it!
}

// MARK: - Resource Load Error
public enum ResourceLoadError: Error, LocalizedError, Sendable {
    case unknown
    case managerNotFound
    case notFound
    case notSupported
    case unexpectedType
    case corrupted
    
    public var errorDescription: String? {
        switch self {
        case .unknown: return "Unknown error"
        case .managerNotFound: return "Resource manager not found"
        case .notFound: return "Resource not found"
        case .notSupported: return "Resource type not supported"
        case .unexpectedType: return "Unexpected resource type"
        case .corrupted: return "Resource data corrupted"
        }
    }
}

// MARK: - Resource Manager Protocol
public protocol ResourceManager: Sendable {
    associatedtype ResourceType: Resource
    
    var resourceType: Any.Type { get }
    
    func load(from path: String) -> Result<ResourceType, ResourceLoadError>
    func load(from data: Data) -> Result<ResourceType, ResourceLoadError>
    func unload(_ resource: ResourceType)
}

// MARK: - Type-erased Resource Manager
public class AnyResourceManager: @unchecked Sendable {
    private let _resourceType: Any.Type
    private let _loadFromPath: @Sendable (String) -> Result<AnyObject, ResourceLoadError>
    private let _loadFromData: @Sendable (Data) -> Result<AnyObject, ResourceLoadError>
    private let _unload: @Sendable (AnyObject) -> Void
    
    public var resourceType: Any.Type { _resourceType }
    
    public init<T: ResourceManager>(_ manager: T) {
        self._resourceType = T.ResourceType.self
        self._loadFromPath = { path in
            manager.load(from: path)
                .map { $0 as AnyObject }
        }
        self._loadFromData = { data in
            manager.load(from: data)
                .map { $0 as AnyObject }
        }
        self._unload = { resource in
            if let typedResource = resource as? T.ResourceType {
                manager.unload(typedResource)
            }
        }
    }
    
    public func load(from path: String) -> Result<AnyObject, ResourceLoadError> {
        return _loadFromPath(path)
    }
    
    public func load(from data: Data) -> Result<AnyObject, ResourceLoadError> {
        return _loadFromData(data)
    }
    
    public func unload(_ resource: AnyObject) {
        _unload(resource)
    }
}

// MARK: - Resource Cache Key
private struct ResourceCacheKey: Hashable, Sendable {
    let identifierHash: Int
    let resourceType: ObjectIdentifier
    
    init(identifier: String, resourceType: Any.Type) {
        self.identifierHash = identifier.hashValue
        self.resourceType = ObjectIdentifier(resourceType)
    }
}

// MARK: - Resource Cache
private actor ResourceCache {
    // Using strong references - ARC will handle cleanup when resources are no longer needed
    private var resources: [ResourceCacheKey: AnyObject] = [:]
    
    func set<T: Resource>(key: ResourceCacheKey, resource: T) {
        resources[key] = resource
    }
    
    func addIfNotExists<T: Resource>(key: ResourceCacheKey, resource: T) {
        if resources[key] == nil {
            resources[key] = resource
        }
    }
    
    func get<T: Resource>(key: ResourceCacheKey, as type: T.Type) -> T? {
        return resources[key] as? T
    }
    
    func remove(key: ResourceCacheKey) {
        resources.removeValue(forKey: key)
    }
    
    func remove<T: Resource>(_ resource: T) {
        let keysToRemove = resources.compactMap { (key, value) in
            (value as? T)?.id == resource.id ? key : nil
        }
        
        for key in keysToRemove {
            resources.removeValue(forKey: key)
        }
    }
    
    func clear() {
        resources.removeAll()
    }
    
    func getAllResources() -> [AnyObject] {
        return Array(resources.values)
    }
}

// MARK: - Load Resource Job
public class LoadResourceJob<T: Resource>: ResultJob<Result<ResourceHandle<T>, ResourceLoadError>>, @unchecked Sendable {
    private nonisolated let resourceSystem: ResourceSystem
    private let path: String
    private let fromCache: Bool
    private let cacheIfLoaded: Bool
    
    public init(
        resourceSystem: ResourceSystem,
        path: String,
        fromCache: Bool = true,
        cacheIfLoaded: Bool = true,
        onCompletedCallback: (@Sendable (Result<ResourceHandle<T>, ResourceLoadError>) -> Void)? = nil
    ) {
        self.resourceSystem = resourceSystem
        self.path = path
        self.fromCache = fromCache
        self.cacheIfLoaded = cacheIfLoaded
        super.init(name: "Load Asset '\(path)'", onCompletedCallback: onCompletedCallback)
    }
    
    public override func onExecute() -> Result<ResourceHandle<T>, ResourceLoadError> {
        // Use a blocking async call since we're in a background job
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<ResourceHandle<T>, ResourceLoadError> = .failure(.unknown)
        
        Task { @MainActor in
            result = await self.resourceSystem.loadResourceAsync(
                path: self.path,
                fromCache: self.fromCache,
                cacheIfLoaded: self.cacheIfLoaded
            )
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
}

// MARK: - Resource System
@MainActor
public class ResourceSystem {
    private let jobSystem: JobSystem
    private let logger: Logger?
    
    private var resourceManagers: [ObjectIdentifier: AnyResourceManager] = [:]
    private let cache = ResourceCache()
    
    public init(logger: Logger? = nil, jobSystem: JobSystem) {
        self.logger = logger
        self.jobSystem = jobSystem
    }
    
    public func startup() {
        logger?.info("ResourceSystem started")
    }
    
    public func shutdown() async {
        // Simply clear the cache - ARC will handle cleanup automatically
        await cache.clear()
        logger?.info("ResourceSystem shut down")
    }
    
    private func getResourceManager<T: Resource>(for type: T.Type) -> AnyResourceManager? {
        return resourceManagers[ObjectIdentifier(type)]
    }
    
    private func getResourceManager(for type: Any.Type) -> AnyResourceManager? {
        return resourceManagers[ObjectIdentifier(type)]
    }
    
    public func addResourceManager<T: ResourceManager>(_ manager: T) {
        let typeId = ObjectIdentifier(T.ResourceType.self)
        if resourceManagers[typeId] != nil {
            logger?.warning("A resource manager has already been registered for type '\(T.ResourceType.self)'")
            return
        }
        resourceManagers[typeId] = AnyResourceManager(manager)
    }
    
    public func removeResourceManager<T: ResourceManager>(_ manager: T) {
        let typeId = ObjectIdentifier(T.ResourceType.self)
        resourceManagers.removeValue(forKey: typeId)
    }
    
    public func addResource<T: Resource>(
        _ resource: T,
        cache: Bool = true
    ) async -> Result<ResourceHandle<T>, ResourceLoadError> {
        guard getResourceManager(for: T.self) != nil else {
            return .failure(.managerNotFound)
        }
        
        if cache {
            let id = resource.id.uuidString
            let cacheKey = ResourceCacheKey(identifier: id, resourceType: T.self)
            await self.cache.set(key: cacheKey, resource: resource)
        }
        
        return .success(ResourceHandle(resource))
    }
    
    // Async version that properly handles cache checks
    public func loadResourceAsync<T: Resource>(
        path: String,
        fromCache: Bool = true,
        cacheIfLoaded: Bool = true
    ) async -> Result<ResourceHandle<T>, ResourceLoadError> {
        let cacheKey = ResourceCacheKey(identifier: path, resourceType: T.self)
        
        if fromCache {
            if let cachedResource = await cache.get(key: cacheKey, as: T.self) {
                return .success(ResourceHandle(cachedResource))
            }
        }
        
        guard let manager = getResourceManager(for: T.self) else {
            return .failure(.managerNotFound)
        }
        
        let loadResult = manager.load(from: path)
        
        switch loadResult {
        case .success(let resource):
            if let typedResource = resource as? T {
                if cacheIfLoaded {
                    await cache.set(key: cacheKey, resource: typedResource)
                }
                return .success(ResourceHandle(typedResource))
            } else {
                return .failure(.unexpectedType)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func loadResourceWithJob<T: Resource>(
        path: String,
        fromCache: Bool = true,
        cacheIfLoaded: Bool = true,
        onCompletedCallback: (@Sendable (Result<ResourceHandle<T>, ResourceLoadError>) -> Void)? = nil
    ) async -> LoadResourceJob<T> {
        let job = LoadResourceJob<T>(
            resourceSystem: self,
            path: path,
            fromCache: fromCache,
            cacheIfLoaded: cacheIfLoaded,
            onCompletedCallback: onCompletedCallback
        )
        await jobSystem.addJob(job)
        return job
    }
    
    public func unloadResource<T: Resource>(_ handle: ResourceHandle<T>) async {
        guard let resource = handle.value else { return }
        
        await cache.remove(resource)
        
        // Note: We can't check reference count with ARC, but that's actually better!
        // ARC automatically manages memory when there are no more strong references
        
        if let manager = getResourceManager(for: type(of: resource)) {
            manager.unload(resource)
        } else {
            logger?.warning("ResourceManager for resource type '\(type(of: resource))' not found.")
        }
    }
    
    // Convenience method to unload by path
    public func unloadResource<T: Resource>(path: String, type: T.Type) async {
        let cacheKey = ResourceCacheKey(identifier: path, resourceType: type)
        await cache.remove(key: cacheKey)
    }
}