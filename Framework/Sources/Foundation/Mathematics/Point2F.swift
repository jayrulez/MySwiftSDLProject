struct Point2F: Hashable, Codable, Equatable {
    var x: Float
    var y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    static let zero = Point2F(0, 0)
    
    // Convert to Vector2
    var toVector2: Vector2 {
        Vector2(x, y)
    }
    
    // Convert to Point2
    var toPoint: Point2 {
        Point2(Int(x), Int(y))
    }
}