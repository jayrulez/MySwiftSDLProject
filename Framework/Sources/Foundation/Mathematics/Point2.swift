struct Point2: Hashable, Codable, Equatable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static let zero = Point2(0, 0)
    
    // Convert to Vector2
    var toVector2: Vector2 {
        Vector2(Float(x), Float(y))
    }
    
    // Convert to Point2F
    var toPoint2F: Point2F {
        Point2F(Float(x), Float(y))
    }
}