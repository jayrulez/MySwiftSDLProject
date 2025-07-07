import Foundation

struct Matrix4x4: Hashable, Codable, Equatable {
    // Column-major storage
    var m11: Float; var m21: Float; var m31: Float; var m41: Float
    var m12: Float; var m22: Float; var m32: Float; var m42: Float
    var m13: Float; var m23: Float; var m33: Float; var m43: Float
    var m14: Float; var m24: Float; var m34: Float; var m44: Float
    
    init(_ m11: Float, _ m12: Float, _ m13: Float, _ m14: Float,
         _ m21: Float, _ m22: Float, _ m23: Float, _ m24: Float,
         _ m31: Float, _ m32: Float, _ m33: Float, _ m34: Float,
         _ m41: Float, _ m42: Float, _ m43: Float, _ m44: Float) {
        self.m11 = m11; self.m12 = m12; self.m13 = m13; self.m14 = m14
        self.m21 = m21; self.m22 = m22; self.m23 = m23; self.m24 = m24
        self.m31 = m31; self.m32 = m32; self.m33 = m33; self.m34 = m34
        self.m41 = m41; self.m42 = m42; self.m43 = m43; self.m44 = m44
    }
    
    static let identity = Matrix4x4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
    
    var translation: Vector3 {
        get { Vector3(m41, m42, m43) }
        set {
            m41 = newValue.x
            m42 = newValue.y
            m43 = newValue.z
        }
    }
}

extension Matrix4x4 {
    static func *(lhs: Matrix4x4, rhs: Matrix4x4) -> Matrix4x4 {
        Matrix4x4(
            lhs.m11 * rhs.m11 + lhs.m12 * rhs.m21 + lhs.m13 * rhs.m31 + lhs.m14 * rhs.m41,
            lhs.m11 * rhs.m12 + lhs.m12 * rhs.m22 + lhs.m13 * rhs.m32 + lhs.m14 * rhs.m42,
            lhs.m11 * rhs.m13 + lhs.m12 * rhs.m23 + lhs.m13 * rhs.m33 + lhs.m14 * rhs.m43,
            lhs.m11 * rhs.m14 + lhs.m12 * rhs.m24 + lhs.m13 * rhs.m34 + lhs.m14 * rhs.m44,
            
            lhs.m21 * rhs.m11 + lhs.m22 * rhs.m21 + lhs.m23 * rhs.m31 + lhs.m24 * rhs.m41,
            lhs.m21 * rhs.m12 + lhs.m22 * rhs.m22 + lhs.m23 * rhs.m32 + lhs.m24 * rhs.m42,
            lhs.m21 * rhs.m13 + lhs.m22 * rhs.m23 + lhs.m23 * rhs.m33 + lhs.m24 * rhs.m43,
            lhs.m21 * rhs.m14 + lhs.m22 * rhs.m24 + lhs.m23 * rhs.m34 + lhs.m24 * rhs.m44,
            
            lhs.m31 * rhs.m11 + lhs.m32 * rhs.m21 + lhs.m33 * rhs.m31 + lhs.m34 * rhs.m41,
            lhs.m31 * rhs.m12 + lhs.m32 * rhs.m22 + lhs.m33 * rhs.m32 + lhs.m34 * rhs.m42,
            lhs.m31 * rhs.m13 + lhs.m32 * rhs.m23 + lhs.m33 * rhs.m33 + lhs.m34 * rhs.m43,
            lhs.m31 * rhs.m14 + lhs.m32 * rhs.m24 + lhs.m33 * rhs.m34 + lhs.m34 * rhs.m44,
            
            lhs.m41 * rhs.m11 + lhs.m42 * rhs.m21 + lhs.m43 * rhs.m31 + lhs.m44 * rhs.m41,
            lhs.m41 * rhs.m12 + lhs.m42 * rhs.m22 + lhs.m43 * rhs.m32 + lhs.m44 * rhs.m42,
            lhs.m41 * rhs.m13 + lhs.m42 * rhs.m23 + lhs.m43 * rhs.m33 + lhs.m44 * rhs.m43,
            lhs.m41 * rhs.m14 + lhs.m42 * rhs.m24 + lhs.m43 * rhs.m34 + lhs.m44 * rhs.m44
        )
    }
    
    static func createTranslation(_ translation: Vector3) -> Matrix4x4 {
        Matrix4x4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            translation.x, translation.y, translation.z, 1
        )
    }
    
    static func createScale(_ scale: Vector3) -> Matrix4x4 {
        Matrix4x4(
            scale.x, 0, 0, 0,
            0, scale.y, 0, 0,
            0, 0, scale.z, 0,
            0, 0, 0, 1
        )
    }
    
    static func createRotationX(_ radians: Float) -> Matrix4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        
        return Matrix4x4(
            1, 0, 0, 0,
            0, cos, sin, 0,
            0, -sin, cos, 0,
            0, 0, 0, 1
        )
    }
    
    static func createRotationY(_ radians: Float) -> Matrix4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        
        return Matrix4x4(
            cos, 0, -sin, 0,
            0, 1, 0, 0,
            sin, 0, cos, 0,
            0, 0, 0, 1
        )
    }
    
    static func createRotationZ(_ radians: Float) -> Matrix4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        
        return Matrix4x4(
            cos, sin, 0, 0,
            -sin, cos, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        )
    }
    
    static func createPerspective(fieldOfView: Float, aspectRatio: Float, nearPlane: Float, farPlane: Float) -> Matrix4x4 {
        let yScale = 1.0 / tan(fieldOfView * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = farPlane - nearPlane
        
        return Matrix4x4(
            xScale, 0, 0, 0,
            0, yScale, 0, 0,
            0, 0, -farPlane / zRange, -1,
            0, 0, -farPlane * nearPlane / zRange, 0
        )
    }
    
    static func createLookAt(eye: Vector3, target: Vector3, up: Vector3) -> Matrix4x4 {
        let zAxis = (eye - target).normalized
        let xAxis = Vector3.cross(up, zAxis).normalized
        let yAxis = Vector3.cross(zAxis, xAxis)
        
        return Matrix4x4(
            xAxis.x, yAxis.x, zAxis.x, 0,
            xAxis.y, yAxis.y, zAxis.y, 0,
            xAxis.z, yAxis.z, zAxis.z, 0,
            -Vector3.dot(xAxis, eye), -Vector3.dot(yAxis, eye), -Vector3.dot(zAxis, eye), 1
        )
    }
}