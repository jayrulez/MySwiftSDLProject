public struct Plane: Hashable, Codable, Equatable, Sendable {
    public var normal: Vector3
    public var distance: Float
    
    public init(_ normal: Vector3, _ distance: Float) {
        self.normal = normal.normalized
        self.distance = distance
    }
    
    public init(normal: Vector3, distance: Float) {
        self.normal = normal.normalized
        self.distance = distance
    }
    
    public init(point: Vector3, normal: Vector3) {
        self.normal = normal.normalized
        self.distance = Vector3.dot(point, self.normal)
    }
    
    public func distanceToPoint(_ point: Vector3) -> Float {
        Vector3.dot(normal, point) - distance
    }
}