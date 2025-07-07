struct BoundingSphere: Hashable, Codable, Equatable {
    var center: Vector3
    var radius: Float
    
    init(_ center: Vector3, _ radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    init(center: Vector3, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    var diameter: Float { radius * 2 }
    var volume: Float { (4.0 / 3.0) * Float.pi * radius * radius * radius }
    var surfaceArea: Float { 4 * Float.pi * radius * radius }
    
    func contains(_ point: Vector3) -> Bool {
        let distance = Vector3.distance(center, point)
        return distance <= radius
    }
    
    func intersects(_ other: BoundingSphere) -> Bool {
        let distance = Vector3.distance(center, other.center)
        return distance <= (radius + other.radius)
    }
}