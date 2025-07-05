public protocol WindowSystem {
    typealias FrameCallback = (Double, Double) -> Void

    var isRunning: Bool { get }
    var primaryWindow: Window? { get }

    func createWindow(_ title: String, _ width: UInt32, _ height: UInt32) -> Window?
    func startMainLoop()
    func stopMainLoop()
    func runOneFrame(_ callback: FrameCallback)
    func requestExit()
}