import Foundation

struct Quaternion: Hashable, Codable, Equatable {
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
    
    static let identity = Quaternion(0, 0, 0, 1)
    
    var length: Float {
        sqrt(x * x + y * y + z * z + w * w)
    }
    
    var lengthSquared: Float {
        x * x + y * y + z * z + w * w
    }
    
    var normalized: Quaternion {
        let len = length
        return len > 0 ? Quaternion(x / len, y / len, z / len, w / len) : Quaternion.identity
    }
    
    var conjugate: Quaternion {
        Quaternion(-x, -y, -z, w)
    }
}

extension Quaternion {
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
}