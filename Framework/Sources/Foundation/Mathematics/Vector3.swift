import Foundation

public struct Vector3: Hashable, Codable, Equatable, Sendable {
    public var x: Float
    public var y: Float
    public var z: Float
    
    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(_ vector2: Vector2, _ z: Float) {
        self.x = vector2.x
        self.y = vector2.y
        self.z = z
    }
    
    public static let zero = Vector3(0, 0, 0)
    public static let one = Vector3(1, 1, 1)
    public static let unitX = Vector3(1, 0, 0)
    public static let unitY = Vector3(0, 1, 0)
    public static let unitZ = Vector3(0, 0, 1)
    public static let up = Vector3(0, 1, 0)
    public static let down = Vector3(0, -1, 0)
    public static let right = Vector3(1, 0, 0)
    public static let left = Vector3(-1, 0, 0)
    public static let forward = Vector3(0, 0, -1)
    public static let backward = Vector3(0, 0, 1)
    
    public var length: Float {
        sqrt(x * x + y * y + z * z)
    }
    
    public var lengthSquared: Float {
        x * x + y * y + z * z
    }
    
    public var normalized: Vector3 {
        let len = length
        return len > 0 ? Vector3(x / len, y / len, z / len) : Vector3.zero
    }
    
    // Convert to Size3
    public var toSize3: Size3 {
        Size3(Int(x), Int(y), Int(z))
    }
    
    // Convert to Vector2
    public var xy: Vector2 {
        Vector2(x, y)
    }
}


public extension Vector3 {
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

    static func transform(_ vector: Vector3, _ quaternion: Quaternion) -> Vector3 {
        let qvec = Vector3(quaternion.x, quaternion.y, quaternion.z)
        let uv = Vector3.cross(qvec, vector)
        let uuv = Vector3.cross(qvec, uv)
        return vector + ((uv * quaternion.w) + uuv) * 2.0
    }
}
