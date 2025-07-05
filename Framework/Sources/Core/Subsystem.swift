open class Subsystem {
    public private(set) var name: String;
    
    public private(set) var context: Context?;

    public init(_ name: String) {
        self.name = name
        self.context = nil
    }

    package func initialize(_ context: Context) {
        self.context = context
        onInitialize(context)
    }

    package func shutdown() {
        onShutdown()
        self.context = nil
    }

    open func onInitialize(_ context: Context) {}
    open func onShutdown() {}
}