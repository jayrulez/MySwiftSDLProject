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