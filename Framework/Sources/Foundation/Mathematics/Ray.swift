struct Ray: Hashable, Codable, Equatable {
    var position: Vector3
    var direction: Vector3
    
    init(_ position: Vector3, _ direction: Vector3) {
        self.position = position
        self.direction = direction.normalized
    }
    
    init(position: Vector3, direction: Vector3) {
        self.position = position
        self.direction = direction.normalized
    }
    
    func getPoint(_ distance: Float) -> Vector3 {
        Vector3(
            position.x + direction.x * distance,
            position.y + direction.y * distance,
            position.z + direction.z * distance
        )
    }
}