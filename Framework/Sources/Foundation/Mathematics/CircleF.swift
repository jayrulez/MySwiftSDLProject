struct CircleF: Hashable, Codable, Equatable {
    var center: Point2F
    var radius: Float
    
    init(_ center: Point2F, _ radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    init(center: Point2F, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    init(x: Float, y: Float, radius: Float) {
        self.center = Point2F(x, y)
        self.radius = radius
    }
    
    var diameter: Float { radius * 2 }
    var area: Float { Float.pi * radius * radius }
    var circumference: Float { 2 * Float.pi * radius }
    
    // Convert to Circle
    var toCircle: Circle {
        Circle(center.toPoint, Int(radius))
    }
}