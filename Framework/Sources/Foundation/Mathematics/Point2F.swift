public struct Point2F: Hashable, Codable, Equatable, Sendable {
    public var x: Float
    public var y: Float
    
    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Point2F(0, 0)
    
    // Convert to Vector2
    public var toVector2: Vector2 {
        Vector2(x, y)
    }
    
    // Convert to Point2
    public var toPoint: Point2 {
        Point2(Int(x), Int(y))
    }
}