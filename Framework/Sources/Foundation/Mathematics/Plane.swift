struct Plane: Hashable, Codable, Equatable {
    var normal: Vector3
    var distance: Float
    
    init(_ normal: Vector3, _ distance: Float) {
        self.normal = normal.normalized
        self.distance = distance
    }
    
    init(normal: Vector3, distance: Float) {
        self.normal = normal.normalized
        self.distance = distance
    }
    
    init(point: Vector3, normal: Vector3) {
        self.normal = normal.normalized
        self.distance = Vector3.dot(point, self.normal)
    }
    
    func distanceToPoint(_ point: Vector3) -> Float {
        Vector3.dot(normal, point) - distance
    }
}