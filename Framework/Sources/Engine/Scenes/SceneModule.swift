open class SceneModule {
    // weak ref to scene
    internal weak var scene: Scene?
    
    // name property
    open var name: String {
        return String(describing: type(of: self))
    }
    
    public init() {}
    
    // internal attach and detach methods
    internal func attach() {
        onAttached()
    }
    
    internal func detach() {
        onDetached()
    }
    
    // abstract attach and detach methods
    open func onAttached() {}
    open func onDetached() {}
}