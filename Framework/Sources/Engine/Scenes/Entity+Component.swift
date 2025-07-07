import Foundation

// MARK: - Component Protocol
public protocol Component: AnyObject {
    var entity: Entity? { get set }
    init()
}

// MARK: - Component Type System
public struct ComponentType: Hashable, CustomStringConvertible {
    public let id: ObjectIdentifier
    public let name: String
    
    public init<T: Component>(_ type: T.Type) {
        self.id = ObjectIdentifier(type)
        self.name = String(describing: type)
    }
    
    public var description: String { name }
}

// MARK: - Entity with Clean Component API
public class Entity {
    public let id = UUID()
    public var name: String
    public weak var scene: Scene?
    public let transform = EntityTransform()
    
    private var components: [ComponentType: Component] = [:]
    
    public init(name: String, scene: Scene) {
        self.name = name
        self.scene = scene
        self.transform.entity = self
    }
    
    // MARK: - Clean Component API
    
    // Add component
    @discardableResult
    public func addComponent<T: Component>(_ componentType: T.Type = T.self) -> T {
        let type = ComponentType(componentType)
        
        if let existing = components[type] as? T {
            return existing
        }
        
        let component = componentType.init()
        component.entity = self
        components[type] = component
        
        // Notify scene
        scene?.componentAdded(to: self, component: component)
        
        return component
    }
    
    // Get component
    public func getComponent<T: Component>(_ componentType: T.Type = T.self) -> T? {
        let type = ComponentType(componentType)
        return components[type] as? T
    }
    
    // Has component
    public func hasComponent<T: Component>(_ componentType: T.Type = T.self) -> Bool {
        let type = ComponentType(componentType)
        return components[type] != nil
    }
    
    // Remove component
    public func removeComponent<T: Component>(_ componentType: T.Type = T.self) {
        let type = ComponentType(componentType)
        if let component = components.removeValue(forKey: type) {
            component.entity = nil
            scene?.componentRemoved(from: self, componentType: type)
        }
    }
    
    // Get all components of a type (useful for multiple components of same type)
    public func getComponents<T: Component>(_ componentType: T.Type = T.self) -> [T] {
        return components.values.compactMap { $0 as? T }
    }
    
    public func hasComponents(_ componentTypes: any Component.Type...) -> Bool {
        return componentTypes.allSatisfy { componentType in
            let type = ComponentType(componentType)
            return hasComponent(type)
        }
    }
    
    // Get multiple components at once (variadic) - returns tuple
    public func getComponents<each T: Component>(_ componentTypes: repeat (each T).Type) -> (repeat (each T)?) {
        return (repeat getComponent(each componentTypes))
    }
    
    // Internal access for scene modules
    internal func hasComponent(_ type: ComponentType) -> Bool {
        return components[type] != nil
    }
    
    internal func getComponent(_ type: ComponentType) -> Component? {
        return components[type]
    }
}