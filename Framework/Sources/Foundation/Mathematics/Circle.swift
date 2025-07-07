public struct Circle: Hashable, Codable, Equatable, Sendable {
    public var center: Point2
    public var radius: Int
    
    public init(_ center: Point2, _ radius: Int) {
        self.center = center
        self.radius = radius
    }
    
    public init(center: Point2, radius: Int) {
        self.center = center
        self.radius = radius
    }
    
    public init(x: Int, y: Int, radius: Int) {
        self.center = Point2(x, y)
        self.radius = radius
    }
    
    public var diameter: Int { radius * 2 }
    public var area: Float { Float.pi * Float(radius * radius) }
    public var circumference: Float { 2 * Float.pi * Float(radius) }
    
    // Convert to CircleF
    public var toCircleF: CircleF {
        CircleF(center.toPoint2F, Float(radius))
    }
}