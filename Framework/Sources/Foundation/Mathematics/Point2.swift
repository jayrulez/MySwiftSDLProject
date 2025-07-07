public struct Point2: Hashable, Codable, Equatable, Sendable {
    public var x: Int
    public var y: Int
    
    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Point2(0, 0)
    
    // Convert to Vector2
    public var toVector2: Vector2 {
        Vector2(Float(x), Float(y))
    }
    
    // Convert to Point2F
    public var toPoint2F: Point2F {
        Point2F(Float(x), Float(y))
    }
}