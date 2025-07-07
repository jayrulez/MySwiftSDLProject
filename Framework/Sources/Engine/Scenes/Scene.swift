import Foundation

public class Scene {
    public let id = UUID()
    private var entities: [UUID: Entity] = [:]
    private var modules: [SceneModule] = []
    private var queries: [EntityQuery] = []

    @discardableResult
    public func addModule<T: SceneModule>(_ module: T) -> T {
        if getModule(ofType: T.self) != nil {
            return getModule(ofType: T.self)!
        }
        
        modules.append(module)
        module.scene = self
        module.attach(to: self)

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
        
        for module in modules {
            module.entityCreated(entity)
        }
        
        for query in queries {
            query.checkEntity(entity)
        }
        
        return entity
    }
    
    public func destroyEntity(_ entity: Entity) {
        guard entities[entity.id] != nil else { return }
        
        // Remove from hierarchy
        entity.removeFromParent()
        
        // Destroy all children recursively
        let children = entity.getAllChildren()
        for child in children {
            destroyEntity(child)
        }
        
        for module in modules {
            module.entityDestroyed(entity)
        }
        
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
    
    // MARK: - Scene Update
    
    public func update(_ updateTime: UpdateTime) {
        // Update all transforms
        updateTransforms()
        
        // Reset transform changed flags
        resetTransformChangedFlags()
    }
    
    private func updateTransforms() {
        // Update transforms in hierarchy order (parents before children)
        let rootEntities = entities.values.filter { $0.parent == nil }
        for entity in rootEntities {
            updateTransformHierarchy(entity)
        }
    }
    
    private func updateTransformHierarchy(_ entity: Entity) {
        entity.transform.updateTransform()
        
        for child in entity.children {
            updateTransformHierarchy(child)
        }
    }
    
    private func resetTransformChangedFlags() {
        for entity in entities.values {
            entity.transform.resetChangedFlag()
        }
    }
    
    // MARK: - Internal notifications
    
    internal func componentAdded(to entity: Entity, component: any Component) {
        for module in modules {
            module.componentAdded(to: entity, component: component)
        }
        
        for query in queries {
            query.checkEntity(entity)
        }
    }
    
    internal func componentRemoved(from entity: Entity, componentType: ComponentType) {
        for module in modules {
            module.componentRemoved(from: entity, componentType: componentType)
        }
        
        for query in queries {
            query.checkEntity(entity)
        }
    }
    
    internal func hierarchyChanged(entity: Entity) {
        // Notify modules of hierarchy changes if needed
        // This could be useful for modules that care about parent-child relationships
    }
}