struct CircleD: Hashable, Codable, Equatable {
    var center: Point2D
    var radius: Double
    
    init(_ center: Point2D, _ radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    init(center: Point2D, radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    init(x: Double, y: Double, radius: Double) {
        self.center = Point2D(x, y)
        self.radius = radius
    }
    
    var diameter: Double { radius * 2 }
    var area: Double { Double.pi * radius * radius }
    var circumference: Double { 2 * Double.pi * radius }
    
    // Convert to Circle
    var toCircle: Circle {
        Circle(center.toPoint, Int(radius))
    }
}