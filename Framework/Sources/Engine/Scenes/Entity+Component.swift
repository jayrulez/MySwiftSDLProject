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

public class Entity {
    public let id = UUID()
    public var name: String
    public weak var scene: Scene?
    public let transform = EntityTransform()
    
    private var mParent: Entity?
    private var mChildren: [Entity] = []
    
    public var parent: Entity? {
        get { mParent }
        set {
            if mParent !== newValue {
                // Remove from old parent
                mParent?.removeChildInternal(self)
                
                // Set new parent
                mParent = newValue
                transform.parent = newValue?.transform
                
                // Add to new parent
                newValue?.addChildInternal(self)
                
                // Notify scene of hierarchy change
                scene?.hierarchyChanged(entity: self)
            }
        }
    }
    
    public var children: [Entity] {
        return Array(mChildren) // Return copy to prevent external modification
    }
    
    public var childCount: Int {
        return mChildren.count
    }
    
    private var components: [ComponentType: Component] = [:]
    
    public init(name: String, scene: Scene? = nil) {
        self.name = name
        self.scene = scene
        self.transform.entity = self
    }
    
    // MARK: - Hierarchy Management
    
    public func addChild(_ child: Entity) {
        child.parent = self
    }
    
    public func removeChild(_ child: Entity) {
        child.parent = nil
    }
    
    public func removeFromParent() {
        parent = nil
    }
    
    public func getChild(at index: Int) -> Entity? {
        guard index >= 0 && index < mChildren.count else { return nil }
        return mChildren[index]
    }
    
    public func getChild(named name: String) -> Entity? {
        return mChildren.first { $0.name == name }
    }
    
    public func findChild(named name: String, recursive: Bool = false) -> Entity? {
        if let child = getChild(named: name) {
            return child
        }
        
        if recursive {
            for child in mChildren {
                if let found = child.findChild(named: name, recursive: true) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    public func getAllChildren(recursive: Bool = false) -> [Entity] {
        var result = Array(mChildren)
        
        if recursive {
            for child in mChildren {
                result.append(contentsOf: child.getAllChildren(recursive: true))
            }
        }
        
        return result
    }
    
    public func isAncestorOf(_ entity: Entity) -> Bool {
        var current = entity.parent
        while let parent = current {
            if parent === self {
                return true
            }
            current = parent.parent
        }
        return false
    }
    
    public func isDescendantOf(_ entity: Entity) -> Bool {
        return entity.isAncestorOf(self)
    }
    
    public var root: Entity {
        var current = self
        while let parent = current.parent {
            current = parent
        }
        return current
    }
    
    public var depth: Int {
        var depth = 0
        var current = parent
        while let parent = current {
            depth += 1
            current = parent.parent
        }
        return depth
    }
    
    // MARK: - Internal Hierarchy Methods
    
    private func addChildInternal(_ child: Entity) {
        if !mChildren.contains(where: { $0 === child }) {
            mChildren.append(child)
        }
    }
    
    private func removeChildInternal(_ child: Entity) {
        mChildren.removeAll { $0 === child }
    }
    
    // MARK: - Component API (unchanged)
    
    @discardableResult
    public func addComponent<T: Component>(_ componentType: T.Type = T.self) -> T {
        let type = ComponentType(componentType)
        
        if let existing = components[type] as? T {
            return existing
        }
        
        let component = componentType.init()
        component.entity = self
        components[type] = component
        
        scene?.componentAdded(to: self, component: component)
        
        return component
    }
    
    public func getComponent<T: Component>(_ componentType: T.Type = T.self) -> T? {
        let type = ComponentType(componentType)
        return components[type] as? T
    }
    
    public func hasComponent<T: Component>(_ componentType: T.Type = T.self) -> Bool {
        let type = ComponentType(componentType)
        return components[type] != nil
    }
    
    public func removeComponent<T: Component>(_ componentType: T.Type = T.self) {
        let type = ComponentType(componentType)
        if let component = components.removeValue(forKey: type) {
            component.entity = nil
            scene?.componentRemoved(from: self, componentType: type)
        }
    }
    
    public func getComponents<T: Component>(_ componentType: T.Type = T.self) -> [T] {
        return components.values.compactMap { $0 as? T }
    }
    
    public func hasComponents(_ componentTypes: any Component.Type...) -> Bool {
        return componentTypes.allSatisfy { componentType in
            let type = ComponentType(componentType)
            return hasComponent(type)
        }
    }
    
    public func getComponents<each T: Component>(_ componentTypes: repeat (each T).Type) -> (repeat (each T)?) {
        return (repeat getComponent(each componentTypes))
    }
    
    internal func hasComponent(_ type: ComponentType) -> Bool {
        return components[type] != nil
    }
    
    internal func getComponent(_ type: ComponentType) -> Component? {
        return components[type]
    }
}