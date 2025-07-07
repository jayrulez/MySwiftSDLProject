public struct CircleF: Hashable, Codable, Equatable, Sendable {
    public var center: Point2F
    public var radius: Float
    
    public init(_ center: Point2F, _ radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    public init(center: Point2F, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    public init(x: Float, y: Float, radius: Float) {
        self.center = Point2F(x, y)
        self.radius = radius
    }
    
    public var diameter: Float { radius * 2 }
    public var area: Float { Float.pi * radius * radius }
    public var circumference: Float { 2 * Float.pi * radius }
    
    // Convert to Circle
    public var toCircle: Circle {
        Circle(center.toPoint, Int(radius))
    }
}