open class Subsystem {
    public let updatePriority: Int

    public init(updatePriority: Int = 0) {
        self.updatePriority = updatePriority
    }

    package func initialize(_ context: Context) {
        onInitialize(context)
    }

    package func shutdown() {
        onShutdown()
    }

    package func preUpdate(_ updateTime: UpdateTime) {
        onPreUpdate(updateTime)
    }

    package func variableUpdate(_ updateTime: UpdateTime) {
        onVariableUpdate(updateTime)
    }

    package func fixedUpdate(_ updateTime: UpdateTime) {
        onFixedUpdate(updateTime)
    }

    package func postUpdate(_ updateTime: UpdateTime) {
        onPostUpdate(updateTime)
    }

    open func onInitialize(_ context: Context) {}
    open func onShutdown() {}
    open func onPreUpdate(_ updateTime: UpdateTime) {}
    open func onVariableUpdate(_ updateTime: UpdateTime) {}
    open func onFixedUpdate(_ updateTime: UpdateTime) {}
    open func onPostUpdate(_ updateTime: UpdateTime) {}
}