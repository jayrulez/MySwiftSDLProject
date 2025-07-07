struct Point2D: Hashable, Codable, Equatable {
    var x: Double
    var y: Double
    
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    static let zero = Point2D(0, 0)
    
    // Convert to Point2
    var toPoint: Point2 {
        Point2(Int(x), Int(y))
    }
}