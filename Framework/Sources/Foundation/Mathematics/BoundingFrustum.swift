public struct BoundingFrustum: Hashable, Codable, Equatable, Sendable {
    public var planes: [Plane] // 6 planes: near, far, left, right, top, bottom
    
    public init(_ planes: [Plane]) {
        precondition(planes.count == 6, "BoundingFrustum requires exactly 6 planes")
        self.planes = planes
    }
    
    public init(matrix: Matrix4x4) {
        // Extract frustum planes from view-projection matrix
        self.planes = BoundingFrustum.extractPlanesFromMatrix(matrix)
    }
    
    public var near: Plane { planes[0] }
    public var far: Plane { planes[1] }
    public var left: Plane { planes[2] }
    public var right: Plane { planes[3] }
    public var top: Plane { planes[4] }
    public var bottom: Plane { planes[5] }
    
    public func contains(_ point: Vector3) -> Bool {
        for plane in planes {
            if plane.distanceToPoint(point) < 0 {
                return false
            }
        }
        return true
    }
    
    public func intersects(_ sphere: BoundingSphere) -> Bool {
        for plane in planes {
            if plane.distanceToPoint(sphere.center) < -sphere.radius {
                return false
            }
        }
        return true
    }
    
    private static func extractPlanesFromMatrix(_ matrix: Matrix4x4) -> [Plane] {
        // Extract frustum planes from view-projection matrix
        // This is a simplified implementation
        var planes: [Plane] = []
        
        // Near plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 + matrix.m13, matrix.m24 + matrix.m23, matrix.m34 + matrix.m33),
            distance: matrix.m44 + matrix.m43
        ))
        
        // Far plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 - matrix.m13, matrix.m24 - matrix.m23, matrix.m34 - matrix.m33),
            distance: matrix.m44 - matrix.m43
        ))
        
        // Left plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 + matrix.m11, matrix.m24 + matrix.m21, matrix.m34 + matrix.m31),
            distance: matrix.m44 + matrix.m41
        ))
        
        // Right plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 - matrix.m11, matrix.m24 - matrix.m21, matrix.m34 - matrix.m31),
            distance: matrix.m44 - matrix.m41
        ))
        
        // Top plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 - matrix.m12, matrix.m24 - matrix.m22, matrix.m34 - matrix.m32),
            distance: matrix.m44 - matrix.m42
        ))
        
        // Bottom plane
        planes.append(Plane(
            normal: Vector3(matrix.m14 + matrix.m12, matrix.m24 + matrix.m22, matrix.m34 + matrix.m32),
            distance: matrix.m44 + matrix.m42
        ))
        
        return planes
    }
}