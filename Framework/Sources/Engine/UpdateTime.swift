public struct UpdateTime {
    public let elapsedTime: Double
    public let totalTime: Double

    public init(_ elapsedTime: Double, _ totalTime: Double) {
        self.elapsedTime = elapsedTime
        self.totalTime = totalTime
    }
}