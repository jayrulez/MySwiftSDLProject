import Foundation
import SedulousResources
import SedulousGeometry

public class MeshResource : BaseResource, @unchecked Sendable {
    public let mesh: Mesh
    
    public init(mesh: Mesh, id: UUID = UUID(), name: String = "") {
        self.mesh = mesh
        super.init(id: id, name: name)
    }
    
    // MARK: - Codable
    public enum CodingKeys: String, CodingKey {
        case mesh
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mesh = try container.decode(Mesh.self, forKey: .mesh)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mesh, forKey: .mesh)
        try super.encode(to: encoder)
    }
}

// MARK: - Mesh Resource Manager
open class MeshResourceManager: ResourceManager, @unchecked Sendable {
    public typealias ResourceType = MeshResource
    
    public var resourceType: Any.Type { MeshResource.self }
    
    public init() {}
    
    public func load(from path: String) -> Result<MeshResource, ResourceLoadError> {
        guard let data = FileManager.default.contents(atPath: path) else {
            return .failure(.notFound)
        }
        return load(from: data)
    }
    
    public func load(from data: Data) -> Result<MeshResource, ResourceLoadError> {
        // TODO: Implement mesh loading from data
        // MeshResourceManager will be passed a MeshLoader to handle actual loading
        
        
        return .failure(.notSupported)
    }
    
    public func unload(_ resource: MeshResource) {
        // No manual cleanup needed - Swift ARC handles it automatically
        // The mesh will be deallocated when the resource is deallocated
        print("Unloading mesh resource: \(resource.name)")
    }
}