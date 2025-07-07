public struct Point2D: Hashable, Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Point2D(0, 0)
    
    // Convert to Point2
    public var toPoint: Point2 {
        Point2(Int(x), Int(y))
    }
}