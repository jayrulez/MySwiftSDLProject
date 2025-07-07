import Foundation

public struct Quaternion: Hashable, Codable, Equatable, Sendable {
    public var x: Float
    public var y: Float
    public var z: Float
    public var w: Float
    
    public init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    public init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    public static let identity = Quaternion(0, 0, 0, 1)
    
    public var length: Float {
        sqrt(x * x + y * y + z * z + w * w)
    }
    
    public var lengthSquared: Float {
        x * x + y * y + z * z + w * w
    }
    
    public var normalized: Quaternion {
        let len = length
        return len > 0 ? Quaternion(x / len, y / len, z / len, w / len) : Quaternion.identity
    }
    
    public var conjugate: Quaternion {
        Quaternion(-x, -y, -z, w)
    }
}

public extension Quaternion {
    static func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        Quaternion(
            lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
            lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x,
            lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
        )
    }
    
    static func slerp(_ start: Quaternion, _ end: Quaternion, _ t: Float) -> Quaternion {
        let dot = start.x * end.x + start.y * end.y + start.z * end.z + start.w * end.w
        
        if abs(dot) > 0.9995 {
            // Linear interpolation for very close quaternions
            let result = Quaternion(
                start.x + t * (end.x - start.x),
                start.y + t * (end.y - start.y),
                start.z + t * (end.z - start.z),
                start.w + t * (end.w - start.w)
            )
            return result.normalized
        }
        
        let theta = acos(abs(dot))
        let sinTheta = sin(theta)
        
        let scale1 = sin((1 - t) * theta) / sinTheta
        let scale2 = sin(t * theta) / sinTheta
        
        if dot < 0 {
            return Quaternion(
                scale1 * start.x - scale2 * end.x,
                scale1 * start.y - scale2 * end.y,
                scale1 * start.z - scale2 * end.z,
                scale1 * start.w - scale2 * end.w
            )
        } else {
            return Quaternion(
                scale1 * start.x + scale2 * end.x,
                scale1 * start.y + scale2 * end.y,
                scale1 * start.z + scale2 * end.z,
                scale1 * start.w + scale2 * end.w
            )
        }
    }

    static func createFromRotationMatrix(_ matrix: Matrix4x4) -> Quaternion {
        let trace = matrix.m11 + matrix.m22 + matrix.m33
        
        if trace > 0 {
            let s = sqrt(trace + 1.0) * 2
            return Quaternion(
                (matrix.m32 - matrix.m23) / s,
                (matrix.m13 - matrix.m31) / s,
                (matrix.m21 - matrix.m12) / s,
                0.25 * s
            )
        } else if matrix.m11 > matrix.m22 && matrix.m11 > matrix.m33 {
            let s = sqrt(1.0 + matrix.m11 - matrix.m22 - matrix.m33) * 2
            return Quaternion(
                0.25 * s,
                (matrix.m12 + matrix.m21) / s,
                (matrix.m13 + matrix.m31) / s,
                (matrix.m32 - matrix.m23) / s
            )
        } else if matrix.m22 > matrix.m33 {
            let s = sqrt(1.0 + matrix.m22 - matrix.m11 - matrix.m33) * 2
            return Quaternion(
                (matrix.m12 + matrix.m21) / s,
                0.25 * s,
                (matrix.m23 + matrix.m32) / s,
                (matrix.m13 - matrix.m31) / s
            )
        } else {
            let s = sqrt(1.0 + matrix.m33 - matrix.m11 - matrix.m22) * 2
            return Quaternion(
                (matrix.m13 + matrix.m31) / s,
                (matrix.m23 + matrix.m32) / s,
                0.25 * s,
                (matrix.m21 - matrix.m12) / s
            )
        }
    }

    static func createFromEuler(_ euler: Vector3) -> Quaternion {
        // ZYX Euler angle conversion
        let cy = cos(euler.z * 0.5)
        let sy = sin(euler.z * 0.5)
        let cp = cos(euler.y * 0.5)
        let sp = sin(euler.y * 0.5)
        let cr = cos(euler.x * 0.5)
        let sr = sin(euler.x * 0.5)
        
        return Quaternion(
            sr * cp * cy - cr * sp * sy,
            cr * sp * cy + sr * cp * sy,
            cr * cp * sy - sr * sp * cy,
            cr * cp * cy + sr * sp * sy
        )
    }
}