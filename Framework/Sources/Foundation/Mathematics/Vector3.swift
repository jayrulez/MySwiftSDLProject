import Foundation

struct Vector3: Hashable, Codable, Equatable {
    var x: Float
    var y: Float
    var z: Float
    
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ vector2: Vector2, _ z: Float) {
        self.x = vector2.x
        self.y = vector2.y
        self.z = z
    }
    
    static let zero = Vector3(0, 0, 0)
    static let one = Vector3(1, 1, 1)
    static let unitX = Vector3(1, 0, 0)
    static let unitY = Vector3(0, 1, 0)
    static let unitZ = Vector3(0, 0, 1)
    static let up = Vector3(0, 1, 0)
    static let down = Vector3(0, -1, 0)
    static let right = Vector3(1, 0, 0)
    static let left = Vector3(-1, 0, 0)
    static let forward = Vector3(0, 0, -1)
    static let backward = Vector3(0, 0, 1)
    
    var length: Float {
        sqrt(x * x + y * y + z * z)
    }
    
    var lengthSquared: Float {
        x * x + y * y + z * z
    }
    
    var normalized: Vector3 {
        let len = length
        return len > 0 ? Vector3(x / len, y / len, z / len) : Vector3.zero
    }
    
    // Convert to Size3
    var toSize3: Size3 {
        Size3(Int(x), Int(y), Int(z))
    }
    
    // Convert to Vector2
    var xy: Vector2 {
        Vector2(x, y)
    }
}


extension Vector3 {
    static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func *(lhs: Vector3, rhs: Float) -> Vector3 {
        Vector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    
    static func *(lhs: Float, rhs: Vector3) -> Vector3 {
        Vector3(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
    }
    
    static func /(lhs: Vector3, rhs: Float) -> Vector3 {
        Vector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    
    static func dot(_ lhs: Vector3, _ rhs: Vector3) -> Float {
        lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }
    
    static func cross(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 {
        Vector3(
            lhs.y * rhs.z - lhs.z * rhs.y,
            lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.x * rhs.y - lhs.y * rhs.x
        )
    }
    
    static func distance(_ lhs: Vector3, _ rhs: Vector3) -> Float {
        (lhs - rhs).length
    }
    
    static func lerp(_ start: Vector3, _ end: Vector3, _ t: Float) -> Vector3 {
        start + (end - start) * t
    }
}
