import Foundation

struct Vector4: Hashable, Codable, Equatable {
    var x: Float
    var y: Float
    var z: Float
    var w: Float
    
    init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    init(_ vector3: Vector3, _ w: Float) {
        self.x = vector3.x
        self.y = vector3.y
        self.z = vector3.z
        self.w = w
    }
    
    static let zero = Vector4(0, 0, 0, 0)
    static let one = Vector4(1, 1, 1, 1)
    static let unitX = Vector4(1, 0, 0, 0)
    static let unitY = Vector4(0, 1, 0, 0)
    static let unitZ = Vector4(0, 0, 1, 0)
    static let unitW = Vector4(0, 0, 0, 1)
    
    var length: Float {
        sqrt(x * x + y * y + z * z + w * w)
    }
    
    var lengthSquared: Float {
        x * x + y * y + z * z + w * w
    }
    
    var normalized: Vector4 {
        let len = length
        return len > 0 ? Vector4(x / len, y / len, z / len, w / len) : Vector4.zero
    }
    
    // Convert to Vector3
    var xyz: Vector3 {
        Vector3(x, y, z)
    }
    
    // Convert to Vector2
    var xy: Vector2 {
        Vector2(x, y)
    }
}

extension Vector4 {
    static func +(lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)
    }
    
    static func -(lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z, lhs.w - rhs.w)
    }
    
    static func *(lhs: Vector4, rhs: Float) -> Vector4 {
        Vector4(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs, lhs.w * rhs)
    }
    
    static func *(lhs: Float, rhs: Vector4) -> Vector4 {
        Vector4(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z, lhs * rhs.w)
    }
    
    static func /(lhs: Vector4, rhs: Float) -> Vector4 {
        Vector4(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs, lhs.w / rhs)
    }
    
    static func dot(_ lhs: Vector4, _ rhs: Vector4) -> Float {
        lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.w * rhs.w
    }
    
    static func distance(_ lhs: Vector4, _ rhs: Vector4) -> Float {
        (lhs - rhs).length
    }
    
    static func lerp(_ start: Vector4, _ end: Vector4, _ t: Float) -> Vector4 {
        start + (end - start) * t
    }
}