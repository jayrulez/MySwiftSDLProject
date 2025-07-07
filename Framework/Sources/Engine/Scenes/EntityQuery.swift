import Foundation

public class EntityQuery {
    private var requiredComponents: Set<ComponentType> = []
    private var anyOfComponents: Set<ComponentType> = []
    private var excludedComponents: Set<ComponentType> = []
    private var matchingEntities: Set<UUID> = []
    
    @discardableResult
    public func with(_ componentTypes: any Component.Type...) -> EntityQuery {
        for componentType in componentTypes {
            requiredComponents.insert(ComponentType(componentType))
        }
        return self
    }

    @discardableResult
    public func withAnyOf(_ componentTypes: any Component.Type...) -> EntityQuery {
        for componentType in componentTypes {
            anyOfComponents.insert(ComponentType(componentType))
        }
        return self
    }

    @discardableResult
    public func without(_ componentTypes: any Component.Type...) -> EntityQuery {
        for componentType in componentTypes {
            excludedComponents.insert(ComponentType(componentType))
        }
        return self
    }
    
    // Get matching entities from scene
    public func getEntities(from scene: Scene) -> [Entity] {
        return matchingEntities.compactMap { entityId in
            scene.findEntity(id: entityId)
        }
    }
    
    public func forEach<T: Component>(
        _ componentType: T.Type,
        in scene: Scene,
        _ action: (Entity, T) -> Void
    ) {
        for entity in getEntities(from: scene) {
            if let component = entity.getComponent(componentType) {
                action(entity, component)
            }
        }
    }

    public func forEach<T1: Component, T2: Component>(
        _ type1: T1.Type, _ type2: T2.Type,
        in scene: Scene,
        _ action: (Entity, T1, T2) -> Void
    ) {
        for entity in getEntities(from: scene) {
            if let comp1 = entity.getComponent(type1),
            let comp2 = entity.getComponent(type2) {
                action(entity, comp1, comp2)
            }
        }
    }
    
    // Check if entity matches this query
    public func matches(_ entity: Entity) -> Bool {
        // All required components must be present
        for requiredType in requiredComponents {
            if !entity.hasComponent(requiredType) {
                return false
            }
        }
        
        // At least one "any of" component must be present (if any specified)
        if !anyOfComponents.isEmpty {
            let hasAnyOf = anyOfComponents.contains { componentType in
                entity.hasComponent(componentType)
            }
            if !hasAnyOf {
                return false
            }
        }
        
        // None of the excluded components can be present
        for excludedType in excludedComponents {
            if entity.hasComponent(excludedType) {
                return false
            }
        }
        
        return true
    }
    
    // Internal management
    internal func checkEntity(_ entity: Entity) {
        if matches(entity) {
            matchingEntities.insert(entity.id)
        } else {
            matchingEntities.remove(entity.id)
        }
    }
    
    internal func removeEntity(_ entity: Entity) {
        matchingEntities.remove(entity.id)
    }
}