import Foundation

public class Scene {
    public let id = UUID()
    //public var name: String
    private var entities: [UUID: Entity] = [:]
    private var modules: [SceneModule] = []
    private var queries: [EntityQuery] = []

    @discardableResult
    public func addModule<T: SceneModule>(_ module: T) -> T {
        // Check if module of this type already exists
        if getModule(ofType: T.self) != nil {
            return getModule(ofType: T.self)!
        }
        
        modules.append(module)
        module.scene = self
        module.attach(to: self)

        // Initialize with existing entities
        for entity in entities.values {
            module.entityCreated(entity)
        }
        
        return module
    }
    
    public func removeModule<T: SceneModule>(ofType type: T.Type) {
        if let index = modules.firstIndex(where: { $0 is T }) {
            let module = modules.remove(at: index)
            module.detach()
            module.scene = nil
        }
    }
    
    public func getModule<T: SceneModule>(ofType type: T.Type) -> T? {
        return modules.first { $0 is T } as? T
    }

    // MARK: - Entity Management
    
    public func createEntity(name: String = "Entity") -> Entity {
        let entity = Entity(name: name, scene: self)
        entities[entity.id] = entity
        
        // Notify modules
        for module in modules {
            module.entityCreated(entity)
        }
        
        // Update queries
        for query in queries {
            query.checkEntity(entity)
        }
        
        return entity
    }
    
    public func destroyEntity(_ entity: Entity) {
        guard entities[entity.id] != nil else { return }
        
        // Notify modules
        for module in modules {
            module.entityDestroyed(entity)
        }
        
        // Update queries
        for query in queries {
            query.removeEntity(entity)
        }
        
        entities.removeValue(forKey: entity.id)
    }
    
    public func findEntity(id: UUID) -> Entity? {
        return entities[id]
    }
    
    public func findEntity(name: String) -> Entity? {
        return entities.values.first { $0.name == name }
    }
    
    // MARK: - Query System
    
    public func createQuery() -> EntityQuery {
        let query = EntityQuery()
        queries.append(query)
        return query
    }
    
    public func destroyQuery(_ query: EntityQuery) {
        if let index = queries.firstIndex(where: { $0 === query }) {
            queries.remove(at: index)
        }
    }
    
    // MARK: - Internal notifications
    
    internal func componentAdded(to entity: Entity, component: any Component) {
        for module in modules {
            module.componentAdded(to: entity, component: component)
        }
        
        // Update queries
        for query in queries {
            query.checkEntity(entity)
        }
    }
    
    internal func componentRemoved(from entity: Entity, componentType: ComponentType) {
        for module in modules {
            module.componentRemoved(from: entity, componentType: componentType)
        }
        
        // Update queries
        for query in queries {
            query.checkEntity(entity)
        }
    }
    
    public func update(_ updateTime: UpdateTime) {
        // todo: entity updates, transforms, etc...
    }
}