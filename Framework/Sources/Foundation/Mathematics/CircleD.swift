public struct CircleD: Hashable, Codable, Equatable, Sendable {
    public var center: Point2D
    public var radius: Double
    
    public init(_ center: Point2D, _ radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    public init(center: Point2D, radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    public init(x: Double, y: Double, radius: Double) {
        self.center = Point2D(x, y)
        self.radius = radius
    }
    
    public var diameter: Double { radius * 2 }
    public var area: Double { Double.pi * radius * radius }
    public var circumference: Double { 2 * Double.pi * radius }
    
    // Convert to Circle
    public var toCircle: Circle {
        Circle(center.toPoint, Int(radius))
    }
}