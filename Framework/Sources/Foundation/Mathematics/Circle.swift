struct Circle: Hashable, Codable, Equatable {
    var center: Point2
    var radius: Int
    
    init(_ center: Point2, _ radius: Int) {
        self.center = center
        self.radius = radius
    }
    
    init(center: Point2, radius: Int) {
        self.center = center
        self.radius = radius
    }
    
    init(x: Int, y: Int, radius: Int) {
        self.center = Point2(x, y)
        self.radius = radius
    }
    
    var diameter: Int { radius * 2 }
    var area: Float { Float.pi * Float(radius * radius) }
    var circumference: Float { 2 * Float.pi * Float(radius) }
    
    // Convert to CircleF
    var toCircleF: CircleF {
        CircleF(center.toPoint2F, Float(radius))
    }
}