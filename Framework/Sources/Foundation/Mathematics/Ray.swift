public struct Ray: Hashable, Codable, Equatable, Sendable {
    public var position: Vector3
    public var direction: Vector3
    
    public init(_ position: Vector3, _ direction: Vector3) {
        self.position = position
        self.direction = direction.normalized
    }
    
    public init(position: Vector3, direction: Vector3) {
        self.position = position
        self.direction = direction.normalized
    }
    
    public func getPoint(_ distance: Float) -> Vector3 {
        Vector3(
            position.x + direction.x * distance,
            position.y + direction.y * distance,
            position.z + direction.z * distance
        )
    }
}