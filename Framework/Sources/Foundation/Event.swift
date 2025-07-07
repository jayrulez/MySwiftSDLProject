import Foundation

// Internal event storage - not exposed publicly
internal final class EventStorage<T> {
    public typealias Handler = (T) -> Void
    private var handlers: [UUID: Handler] = [:]

    internal init() {}

    internal func subscribe(_ handler: @escaping Handler) -> UUID {
        let id = UUID()
        handlers[id] = handler
        return id
    }

    internal func unsubscribe(_ id: UUID) {
        handlers.removeValue(forKey: id)
    }

    internal func invoke(_ data: T) {
        for h in handlers.values {
            h(data)
        }
    }
}

// Public Event interface - what users declare and interact with
public struct Event<T> {
    private let storage: EventStorage<T>

    internal init(storage: EventStorage<T>) {
        self.storage = storage
    }

    public func subscribe(_ handler: @escaping (T) -> Void) -> UUID {
        storage.subscribe(handler)
    }

    public func unsubscribe(_ id: UUID) {
        storage.unsubscribe(id)
    }

    public static func += (lhs: Event<T>, rhs: @escaping (T) -> Void) {
        _ = lhs.subscribe(rhs)
    }
}

// Manager that encapsulates both subscription and raising capabilities
// Made public so it can be used by the macro in other modules
public final class EventSubscriptionManager<T> {
    private let storage = EventStorage<T>()
    
    public var event: Event<T> {
        Event(storage: storage)
    }
    
    public init() {}
    
    public func raise(_ value: T) {
        storage.invoke(value)
    }
}