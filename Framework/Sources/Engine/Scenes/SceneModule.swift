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
}