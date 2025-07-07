public struct BoundingSphere: Hashable, Codable, Equatable, Sendable {
    public var center: Vector3
    public var radius: Float
    
    public init(_ center: Vector3, _ radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    public init(center: Vector3, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    public var diameter: Float { radius * 2 }
    public var volume: Float { (4.0 / 3.0) * Float.pi * radius * radius * radius }
    public var surfaceArea: Float { 4 * Float.pi * radius * radius }
    
    public func contains(_ point: Vector3) -> Bool {
        let distance = Vector3.distance(center, point)
        return distance <= radius
    }
    
    public func intersects(_ other: BoundingSphere) -> Bool {
        let distance = Vector3.distance(center, other.center)
        return distance <= (radius + other.radius)
    }
}