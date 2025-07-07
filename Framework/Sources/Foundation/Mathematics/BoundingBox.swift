struct BoundingBox: Hashable, Codable, Equatable {
    var min: Vector3
    var max: Vector3
    
    init(_ min: Vector3, _ max: Vector3) {
        self.min = min
        self.max = max
    }
    
    init(min: Vector3, max: Vector3) {
        self.min = min
        self.max = max
    }
    
    init(center: Vector3, size: Vector3) {
        let halfSize = Vector3(size.x / 2, size.y / 2, size.z / 2)
        self.min = Vector3(center.x - halfSize.x, center.y - halfSize.y, center.z - halfSize.z)
        self.max = Vector3(center.x + halfSize.x, center.y + halfSize.y, center.z + halfSize.z)
    }
    
    var center: Vector3 {
        Vector3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
    }
    
    var size: Vector3 {
        Vector3(max.x - min.x, max.y - min.y, max.z - min.z)
    }
    
    var volume: Float {
        let s = size
        return s.x * s.y * s.z
    }
    
    func contains(_ point: Vector3) -> Bool {
        point.x >= min.x && point.x <= max.x &&
        point.y >= min.y && point.y <= max.y &&
        point.z >= min.z && point.z <= max.z
    }
    
    func intersects(_ other: BoundingBox) -> Bool {
        min.x <= other.max.x && max.x >= other.min.x &&
        min.y <= other.max.y && max.y >= other.min.y &&
        min.z <= other.max.z && max.z >= other.min.z
    }
}