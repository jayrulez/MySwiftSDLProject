open class SceneModule {
    internal weak var scene: Scene?
    
    open var name: String {
        return String(describing: type(of: self))
    }
    
    public init() {}
    
    internal func attach(to scene: Scene) {
        self.scene = scene
        onAttached(to: scene)
    }
    
    internal func detach() {
        onDetached()
        self.scene = nil
    }
    
    open func onAttached(to scene: Scene) {}
    open func onDetached() {}

    // MARK: - Query System
    
    public func createQuery() -> EntityQuery? {
        return scene?.createQuery()
    }

    // MARK: - Entity Events (optional overrides)
    open func onEntityCreated(_ entity: Entity) {}
    open func onEntityDestroyed(_ entity: Entity) {}
    open func onComponentAdded(to entity: Entity, component: any Component) {}
    open func onComponentRemoved(from entity: Entity, componentType: ComponentType) {}
    
    // Internal query management
    internal func entityCreated(_ entity: Entity) {
        onEntityCreated(entity)
    }
    
    internal func entityDestroyed(_ entity: Entity) {
        onEntityDestroyed(entity)
    }
    
    internal func componentAdded(to entity: Entity, component: any Component) {
        onComponentAdded(to: entity, component: component)
    }
    
    internal func componentRemoved(from entity: Entity, componentType: ComponentType) {
        onComponentRemoved(from: entity, componentType: componentType)
    }
}