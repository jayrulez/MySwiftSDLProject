import Foundation
import SedulousFoundation

public class Mesh {
    private var vertexBuffer: VertexBuffer?
    private var indexBuffer: IndexBuffer?
    private var subMeshes: [SubMesh]
    private var bounds: BoundingBox
    private var boundsDirty: Bool = true
    
    // Common vertex data accessors
    private var positionOffset: Int = -1
    private var normalOffset: Int = -1
    private var uvOffset: Int = -1
    private var colorOffset: Int = -1
    private var tangentOffset: Int = -1
    
    public var vertices: VertexBuffer? { return vertexBuffer }
    public var indices: IndexBuffer? { return indexBuffer }
    public var meshes: [SubMesh] { return subMeshes }
    
    public init() {
        self.subMeshes = []
        self.bounds = BoundingBox(Vector3.zero, Vector3.zero)
    }
    
    // Initialize with a specific vertex format
    public func initialize(vertexSize: Int, indexFormat: IndexBuffer.IndexFormat = .uint32) {
        vertexBuffer = VertexBuffer(vertexSize: vertexSize)
        indexBuffer = IndexBuffer(format: indexFormat)
    }
    
    // Common vertex format setup (position, normal, uv, color, tangent)
    public func setupCommonVertexFormat() {
        initialize(vertexSize: MemoryLayout<Vector3>.size + MemoryLayout<Vector3>.size + MemoryLayout<Vector2>.size + MemoryLayout<UInt32>.size + MemoryLayout<Vector3>.size)
        
        positionOffset = 0
        vertexBuffer?.addAttribute(name: "position", type: .vec3, offset: positionOffset, size: MemoryLayout<Vector3>.size)
        
        normalOffset = MemoryLayout<Vector3>.size
        vertexBuffer?.addAttribute(name: "normal", type: .vec3, offset: normalOffset, size: MemoryLayout<Vector3>.size)
        
        uvOffset = MemoryLayout<Vector3>.size * 2
        vertexBuffer?.addAttribute(name: "uv", type: .vec2, offset: uvOffset, size: MemoryLayout<Vector2>.size)
        
        colorOffset = MemoryLayout<Vector3>.size * 2 + MemoryLayout<Vector2>.size
        vertexBuffer?.addAttribute(name: "color", type: .color32, offset: colorOffset, size: MemoryLayout<UInt32>.size)
        
        tangentOffset = MemoryLayout<Vector3>.size * 2 + MemoryLayout<Vector2>.size + MemoryLayout<UInt32>.size
        vertexBuffer?.addAttribute(name: "tangent", type: .vec3, offset: tangentOffset, size: MemoryLayout<Vector3>.size)
    }
    
    // Vertex data helpers
    public func setPosition(_ vertexIndex: Int, position: Vector3) {
        if positionOffset >= 0 {
            vertexBuffer?.setVertexData(vertexIndex, offset: positionOffset, value: position)
            boundsDirty = true
        }
    }
    
    public func getPosition(_ vertexIndex: Int) -> Vector3 {
        if positionOffset >= 0 {
            return vertexBuffer?.getVertexData(vertexIndex, offset: positionOffset, as: Vector3.self) ?? Vector3.zero
        }
        return Vector3.zero
    }
    
    public func setNormal(_ vertexIndex: Int, normal: Vector3) {
        if normalOffset >= 0 {
            vertexBuffer?.setVertexData(vertexIndex, offset: normalOffset, value: normal)
        }
    }
    
    public func getNormal(_ vertexIndex: Int) -> Vector3 {
        if normalOffset >= 0 {
            return vertexBuffer?.getVertexData(vertexIndex, offset: normalOffset, as: Vector3.self) ?? Vector3.zero
        }
        return Vector3.zero
    }
    
    public func setUV(_ vertexIndex: Int, uv: Vector2) {
        if uvOffset >= 0 {
            vertexBuffer?.setVertexData(vertexIndex, offset: uvOffset, value: uv)
        }
    }
    
    public func getUV(_ vertexIndex: Int) -> Vector2 {
        if uvOffset >= 0 {
            return vertexBuffer?.getVertexData(vertexIndex, offset: uvOffset, as: Vector2.self) ?? Vector2.zero
        }
        return Vector2.zero
    }
    
    public func setColor(_ vertexIndex: Int, color: UInt32) {
        if colorOffset >= 0 {
            vertexBuffer?.setVertexData(vertexIndex, offset: colorOffset, value: color)
        }
    }
    
    public func setTangent(_ vertexIndex: Int, tangent: Vector3) {
        if tangentOffset >= 0 {
            vertexBuffer?.setVertexData(vertexIndex, offset: tangentOffset, value: tangent)
        }
    }
    
    public func getTangent(_ vertexIndex: Int) -> Vector3 {
        if tangentOffset >= 0 {
            return vertexBuffer?.getVertexData(vertexIndex, offset: tangentOffset, as: Vector3.self) ?? Vector3.zero
        }
        return Vector3.zero
    }
    
    // Direct vertex buffer access for custom formats
    public func setVertexAttribute<T>(_ vertexIndex: Int, attributeOffset: Int, value: T) {
        vertexBuffer?.setVertexData(vertexIndex, offset: attributeOffset, value: value)
    }
    
    public func getVertexAttribute<T>(_ vertexIndex: Int, attributeOffset: Int, as type: T.Type) -> T? {
        return vertexBuffer?.getVertexData(vertexIndex, offset: attributeOffset, as: type)
    }
    
    // Add a sub-mesh
    public func addSubMesh(_ subMesh: SubMesh) {
        subMeshes.append(subMesh)
    }
    
    // Generate tangent vectors for normal mapping
    public func generateTangents() {
        guard let vertexBuffer = vertexBuffer,
              let indexBuffer = indexBuffer,
              vertexBuffer.count > 0,
              indexBuffer.count > 0,
              tangentOffset >= 0 else { return }
        
        // Initialize tangents to zero
        for i in 0..<vertexBuffer.count {
            setTangent(i, tangent: Vector3.zero)
        }
        
        // Calculate tangents for each triangle
        for i in stride(from: 0, to: indexBuffer.count, by: 3) {
            let i0 = Int(indexBuffer.getIndex(i))
            let i1 = Int(indexBuffer.getIndex(i + 1))
            let i2 = Int(indexBuffer.getIndex(i + 2))
            
            calculateTriangleTangent(i0, i1, i2)
        }
        
        // Normalize and orthogonalize tangents
        for i in 0..<vertexBuffer.count {
            var tangent = getTangent(i)
            let normal = getNormal(i)
            
            if tangent.lengthSquared > 0.0001 {
                // Gram-Schmidt orthogonalization
                tangent = tangent - normal * Vector3.dot(normal, tangent)
                
                if tangent.lengthSquared > 0.0001 {
                    setTangent(i, tangent: tangent.normalized)
                } else {
                    // Generate a default tangent if orthogonalization failed
                    generateDefaultTangent(i)
                }
            } else {
                // Generate a default tangent if none exists
                generateDefaultTangent(i)
            }
        }
    }
    
    private func calculateTriangleTangent(_ i0: Int, _ i1: Int, _ i2: Int) {
        let v0 = getPosition(i0)
        let v1 = getPosition(i1)
        let v2 = getPosition(i2)
        
        let uv0 = getUV(i0)
        let uv1 = getUV(i1)
        let uv2 = getUV(i2)
        
        // Calculate edge vectors
        let deltaPos1 = v1 - v0
        let deltaPos2 = v2 - v0
        
        let deltaUV1 = uv1 - uv0
        let deltaUV2 = uv2 - uv0
        
        // Calculate tangent using the standard formula
        let denominator = deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y
        
        var tangent = Vector3.zero
        if abs(denominator) > 0.0001 {
            let r = 1.0 / denominator
            tangent = (deltaPos1 * deltaUV2.y - deltaPos2 * deltaUV1.y) * r
        }
        
        // Add to each vertex's tangent (we'll normalize later)
        setTangent(i0, tangent: getTangent(i0) + tangent)
        setTangent(i1, tangent: getTangent(i1) + tangent)
        setTangent(i2, tangent: getTangent(i2) + tangent)
    }
    
    private func generateDefaultTangent(_ vertexIndex: Int) {
        let normal = getNormal(vertexIndex)
        
        // Create a tangent perpendicular to the normal
        var defaultTangent: Vector3
        if abs(normal.y) < 0.9 {
            defaultTangent = Vector3.cross(normal, Vector3.up)
        } else {
            defaultTangent = Vector3.cross(normal, Vector3.right)
        }
        
        if defaultTangent.lengthSquared > 0.0001 {
            setTangent(vertexIndex, tangent: defaultTangent.normalized)
        } else {
            // Fallback
            setTangent(vertexIndex, tangent: Vector3.right)
        }
    }
    
    // Compute bounds
    public func getBounds() -> BoundingBox {
        if boundsDirty && positionOffset >= 0 {
            if let vertexBuffer = vertexBuffer, vertexBuffer.count > 0 {
                let firstPos = getPosition(0)
                bounds = BoundingBox(firstPos, firstPos)
                
                for i in 1..<vertexBuffer.count {
                    bounds.expand(getPosition(i))
                }
            } else {
                bounds = BoundingBox(Vector3.zero, Vector3.zero)
            }
            boundsDirty = false
        }
        return bounds
    }
    
    // MARK: - Static Factory Methods
    
    // Create a simple triangle mesh
    public static func createTriangle() -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        mesh.vertices?.resize(3)
        mesh.indices?.resize(3)
        
        // Vertices
        mesh.setPosition(0, position: Vector3(-1, -1, 0))
        mesh.setPosition(1, position: Vector3(1, -1, 0))
        mesh.setPosition(2, position: Vector3(0, 1, 0))
        
        mesh.setNormal(0, normal: Vector3(0, 0, 1))
        mesh.setNormal(1, normal: Vector3(0, 0, 1))
        mesh.setNormal(2, normal: Vector3(0, 0, 1))
        
        mesh.setUV(0, uv: Vector2(0, 1))
        mesh.setUV(1, uv: Vector2(1, 1))
        mesh.setUV(2, uv: Vector2(0.5, 0))
        
        // Set default white color
        for i in 0..<3 {
            mesh.setColor(i, color: 0xFFFFFFFF)
        }
        
        // Indices
        mesh.indices?.setIndex(0, value: 0)
        mesh.indices?.setIndex(1, value: 1)
        mesh.indices?.setIndex(2, value: 2)
        
        // Generate tangents
        mesh.generateTangents()
        
        // Sub-mesh
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: 3))
        
        return mesh
    }
    
    // Create a quad mesh
    public static func createQuad(width: Float = 1.0, height: Float = 1.0) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        mesh.vertices?.resize(4)
        mesh.indices?.resize(6)
        
        let hw = width * 0.5
        let hh = height * 0.5
        
        // Vertices
        mesh.setPosition(0, position: Vector3(-hw, -hh, 0))
        mesh.setPosition(1, position: Vector3(hw, -hh, 0))
        mesh.setPosition(2, position: Vector3(hw, hh, 0))
        mesh.setPosition(3, position: Vector3(-hw, hh, 0))
        
        for i in 0..<4 {
            mesh.setNormal(i, normal: Vector3(0, 0, 1))
            mesh.setColor(i, color: 0xFFFFFFFF)
        }
        
        mesh.setUV(0, uv: Vector2(0, 1))
        mesh.setUV(1, uv: Vector2(1, 1))
        mesh.setUV(2, uv: Vector2(1, 0))
        mesh.setUV(3, uv: Vector2(0, 0))
        
        // Indices
        mesh.indices?.setIndex(0, value: 0)
        mesh.indices?.setIndex(1, value: 1)
        mesh.indices?.setIndex(2, value: 2)
        mesh.indices?.setIndex(3, value: 0)
        mesh.indices?.setIndex(4, value: 2)
        mesh.indices?.setIndex(5, value: 3)
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: 6))
        
        return mesh
    }
    
    // Create a cube mesh
    public static func createCube(size: Float = 1.0) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        // 24 vertices (4 per face, no sharing due to different normals)
        mesh.vertices?.resize(24)
        mesh.indices?.resize(36)
        
        let h = size * 0.5
        
        // Positions and normals for each face
        let positions: [Vector3] = [
            // Front face
            Vector3(-h, -h, h), Vector3(h, -h, h), Vector3(h, h, h), Vector3(-h, h, h),
            // Back face
            Vector3(h, -h, -h), Vector3(-h, -h, -h), Vector3(-h, h, -h), Vector3(h, h, -h),
            // Top face
            Vector3(-h, h, h), Vector3(h, h, h), Vector3(h, h, -h), Vector3(-h, h, -h),
            // Bottom face
            Vector3(-h, -h, -h), Vector3(h, -h, -h), Vector3(h, -h, h), Vector3(-h, -h, h),
            // Right face
            Vector3(h, -h, h), Vector3(h, -h, -h), Vector3(h, h, -h), Vector3(h, h, h),
            // Left face
            Vector3(-h, -h, -h), Vector3(-h, -h, h), Vector3(-h, h, h), Vector3(-h, h, -h)
        ]
        
        let normals: [Vector3] = [
            Vector3(0, 0, 1),   // Front
            Vector3(0, 0, -1),  // Back
            Vector3(0, 1, 0),   // Top
            Vector3(0, -1, 0),  // Bottom
            Vector3(1, 0, 0),   // Right
            Vector3(-1, 0, 0)   // Left
        ]
        
        // Set vertices
        for i in 0..<24 {
            mesh.setPosition(i, position: positions[i])
            mesh.setNormal(i, normal: normals[i / 4])
            mesh.setColor(i, color: 0xFFFFFFFF)
            
            // Simple UV mapping
            let faceVertex = i % 4
            switch faceVertex {
            case 0: mesh.setUV(i, uv: Vector2(0, 1))
            case 1: mesh.setUV(i, uv: Vector2(1, 1))
            case 2: mesh.setUV(i, uv: Vector2(1, 0))
            case 3: mesh.setUV(i, uv: Vector2(0, 0))
            default: break
            }
        }
        
        // Set indices with REVERSED winding order
        var idx = 0
        for face in 0..<6 {
            let baseVertex = face * 4
            
            // Reversed winding: 0,2,1 instead of 0,1,2
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 0)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 2)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 1)); idx += 1
            
            // Reversed winding: 0,3,2 instead of 0,2,3
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 0)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 3)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseVertex + 2)); idx += 1
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: 36))
        return mesh
    }
    
    // Create a sphere mesh
    public static func createSphere(radius: Float = 0.5, segments: Int = 32, rings: Int = 16) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        let vertexCount = (rings + 1) * (segments + 1)
        let indexCount = rings * segments * 6
        
        mesh.vertices?.resize(vertexCount)
        mesh.indices?.resize(indexCount)
        
        // Generate vertices
        var v = 0
        for y in 0...rings {
            let ringAngle = Float.pi * Float(y) / Float(rings)
            let ringRadius = sin(ringAngle)
            let ringY = cos(ringAngle)
            
            for x in 0...segments {
                let segmentAngle = 2.0 * Float.pi * Float(x) / Float(segments)
                
                let pos = Vector3(
                    cos(segmentAngle) * ringRadius * radius,
                    ringY * radius,
                    sin(segmentAngle) * ringRadius * radius
                )
                
                mesh.setPosition(v, position: pos)
                mesh.setNormal(v, normal: Vector3(pos.x / radius, pos.y / radius, pos.z / radius))
                mesh.setUV(v, uv: Vector2(Float(x) / Float(segments), Float(y) / Float(rings)))
                mesh.setColor(v, color: 0xFFFFFFFF)
                v += 1
            }
        }
        
        // Generate indices with REVERSED winding order
        var idx = 0
        for y in 0..<rings {
            for x in 0..<segments {
                let a = y * (segments + 1) + x
                let b = a + 1
                let c = a + segments + 1
                let d = c + 1
                
                // First triangle (reversed: a,b,c -> a,c,b)
                mesh.indices?.setIndex(idx, value: UInt32(a)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
                
                // Second triangle (reversed: b,c,d -> b,d,c)
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(d)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
            }
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: indexCount))
        return mesh
    }
    
    // Create a cylinder mesh
    public static func createCylinder(radius: Float = 0.5, height: Float = 1.0, segments: Int = 32) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        // Vertices: top center + top ring + bottom center + bottom ring + side vertices
        // Side vertices need to be duplicated for proper normals
        let vertexCount = 1 + segments + 1 + segments + (segments + 1) * 2
        let indexCount = segments * 3 * 2 + segments * 6 // top cap + bottom cap + sides
        
        mesh.vertices?.resize(vertexCount)
        mesh.indices?.resize(indexCount)
        
        let halfHeight = height * 0.5
        var v = 0
        
        // Top center
        mesh.setPosition(v, position: Vector3(0, halfHeight, 0))
        mesh.setNormal(v, normal: Vector3(0, 1, 0))
        mesh.setUV(v, uv: Vector2(0.5, 0.5))
        mesh.setColor(v, color: 0xFFFFFFFF)
        let topCenterIdx = v
        v += 1
        
        // Top ring (for cap)
        let topRingStart = v
        for i in 0..<segments {
            let angle = 2.0 * Float.pi * Float(i) / Float(segments)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            mesh.setPosition(v, position: Vector3(x, halfHeight, z))
            mesh.setNormal(v, normal: Vector3(0, 1, 0))
            mesh.setUV(v, uv: Vector2(x / radius * 0.5 + 0.5, z / radius * 0.5 + 0.5))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
        }
        
        // Bottom center
        mesh.setPosition(v, position: Vector3(0, -halfHeight, 0))
        mesh.setNormal(v, normal: Vector3(0, -1, 0))
        mesh.setUV(v, uv: Vector2(0.5, 0.5))
        mesh.setColor(v, color: 0xFFFFFFFF)
        let bottomCenterIdx = v
        v += 1
        
        // Bottom ring (for cap)
        let bottomRingStart = v
        for i in 0..<segments {
            let angle = 2.0 * Float.pi * Float(i) / Float(segments)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            mesh.setPosition(v, position: Vector3(x, -halfHeight, z))
            mesh.setNormal(v, normal: Vector3(0, -1, 0))
            mesh.setUV(v, uv: Vector2(x / radius * 0.5 + 0.5, z / radius * 0.5 + 0.5))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
        }
        
        // Side vertices (duplicated for proper normals and UVs)
        let sideStart = v
        for i in 0...segments {
            let angle = 2.0 * Float.pi * Float(i) / Float(segments)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            let normal = Vector3(x, 0, z).normalized
            
            // Top vertex for side
            mesh.setPosition(v, position: Vector3(x, halfHeight, z))
            mesh.setNormal(v, normal: normal)
            mesh.setUV(v, uv: Vector2(Float(i) / Float(segments), 0))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
            
            // Bottom vertex for side
            mesh.setPosition(v, position: Vector3(x, -halfHeight, z))
            mesh.setNormal(v, normal: normal)
            mesh.setUV(v, uv: Vector2(Float(i) / Float(segments), 1))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
        }
        
        // Generate indices
        var idx = 0
        
        // Top cap (counter-clockwise when viewed from above)
        for i in 0..<segments {
            mesh.indices?.setIndex(idx, value: UInt32(topCenterIdx)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(topRingStart + i)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(topRingStart + (i + 1) % segments)); idx += 1
        }
        
        // Bottom cap (clockwise when viewed from above, counter-clockwise from below)
        for i in 0..<segments {
            mesh.indices?.setIndex(idx, value: UInt32(bottomCenterIdx)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(bottomRingStart + (i + 1) % segments)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(bottomRingStart + i)); idx += 1
        }
        
        // Sides
        for i in 0..<segments {
            let topLeft = sideStart + i * 2
            let bottomLeft = topLeft + 1
            let topRight = topLeft + 2
            let bottomRight = topRight + 1
            
            // First triangle
            mesh.indices?.setIndex(idx, value: UInt32(topLeft)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(bottomLeft)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(topRight)); idx += 1
            
            // Second triangle
            mesh.indices?.setIndex(idx, value: UInt32(topRight)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(bottomLeft)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(bottomRight)); idx += 1
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: indexCount))
        return mesh
    }
    
    // Create a cone mesh
    public static func createCone(radius: Float = 0.5, height: Float = 1.0, segments: Int = 32) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        let vertexCount = 1 + segments * 2 + 1 // tip + base ring + base center
        let indexCount = segments * 6 // sides + base
        
        mesh.vertices?.resize(vertexCount)
        mesh.indices?.resize(indexCount)
        
        let halfHeight = height * 0.5
        var v = 0
        
        // Tip vertex
        mesh.setPosition(v, position: Vector3(0, halfHeight, 0))
        mesh.setNormal(v, normal: Vector3(0, 1, 0)) // Simplified normal
        mesh.setUV(v, uv: Vector2(0.5, 0))
        mesh.setColor(v, color: 0xFFFFFFFF)
        v += 1
        
        // Base ring vertices (for sides)
        for i in 0..<segments {
            let angle = 2.0 * Float.pi * Float(i) / Float(segments)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            // Calculate proper normal for cone surface
            var normal = Vector3(x, radius, z)
            let len = sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
            normal.x /= len
            normal.y /= len
            normal.z /= len
            
            mesh.setPosition(v, position: Vector3(x, -halfHeight, z))
            mesh.setNormal(v, normal: normal)
            mesh.setUV(v, uv: Vector2(Float(i) / Float(segments), 1))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
        }
        
        // Base center
        mesh.setPosition(v, position: Vector3(0, -halfHeight, 0))
        mesh.setNormal(v, normal: Vector3(0, -1, 0))
        mesh.setUV(v, uv: Vector2(0.5, 0.5))
        mesh.setColor(v, color: 0xFFFFFFFF)
        let baseCenterIdx = v
        v += 1
        
        // Base ring vertices (for bottom cap)
        for i in 0..<segments {
            let angle = 2.0 * Float.pi * Float(i) / Float(segments)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            mesh.setPosition(v, position: Vector3(x, -halfHeight, z))
            mesh.setNormal(v, normal: Vector3(0, -1, 0))
            mesh.setUV(v, uv: Vector2(x / radius * 0.5 + 0.5, z / radius * 0.5 + 0.5))
            mesh.setColor(v, color: 0xFFFFFFFF)
            v += 1
        }
        
        // Generate indices with REVERSED winding order
        var idx = 0
        
        // Cone sides (reversed)
        for i in 0..<segments {
            mesh.indices?.setIndex(idx, value: 0); idx += 1 // tip
            mesh.indices?.setIndex(idx, value: UInt32(1 + i)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(1 + (i + 1) % segments)); idx += 1
        }
        
        // Base (reversed)
        for i in 0..<segments {
            mesh.indices?.setIndex(idx, value: UInt32(baseCenterIdx)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseCenterIdx + 1 + (i + 1) % segments)); idx += 1
            mesh.indices?.setIndex(idx, value: UInt32(baseCenterIdx + 1 + i)); idx += 1
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: indexCount))
        return mesh
    }
    
    // Create a torus mesh
    public static func createTorus(radius: Float = 1.0, tubeRadius: Float = 0.3, segments: Int = 32, tubeSegments: Int = 16) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        let vertexCount = (segments + 1) * (tubeSegments + 1)
        let indexCount = segments * tubeSegments * 6
        
        mesh.vertices?.resize(vertexCount)
        mesh.indices?.resize(indexCount)
        
        // Generate vertices
        var v = 0
        for i in 0...segments {
            let u = Float(i) / Float(segments)
            let theta = u * 2.0 * Float.pi
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)
            
            for j in 0...tubeSegments {
                let v2 = Float(j) / Float(tubeSegments)
                let phi = v2 * 2.0 * Float.pi
                let cosPhi = cos(phi)
                let sinPhi = sin(phi)
                
                let x = (radius + tubeRadius * cosPhi) * cosTheta
                let y = tubeRadius * sinPhi
                let z = (radius + tubeRadius * cosPhi) * sinTheta
                
                let position = Vector3(x, y, z)
                let center = Vector3(radius * cosTheta, 0, radius * sinTheta)
                var normal = position - center
                let len = sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
                normal.x /= len
                normal.y /= len
                normal.z /= len
                
                mesh.setPosition(v, position: position)
                mesh.setNormal(v, normal: normal)
                mesh.setUV(v, uv: Vector2(u, v2))
                mesh.setColor(v, color: 0xFFFFFFFF)
                v += 1
            }
        }
        
        // Generate indices
        var idx = 0
        for i in 0..<segments {
            for j in 0..<tubeSegments {
                let a = i * (tubeSegments + 1) + j
                let b = a + 1
                let c = a + tubeSegments + 1
                let d = c + 1
                
                mesh.indices?.setIndex(idx, value: UInt32(a)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(d)); idx += 1
            }
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: indexCount))
        
        return mesh
    }
    
    // Create a plane mesh with subdivisions
    public static func createPlane(width: Float = 10.0, depth: Float = 10.0, widthSegments: Int = 10, depthSegments: Int = 10) -> Mesh {
        let mesh = Mesh()
        mesh.setupCommonVertexFormat()
        
        let vertexCount = (widthSegments + 1) * (depthSegments + 1)
        let indexCount = widthSegments * depthSegments * 6
        
        mesh.vertices?.resize(vertexCount)
        mesh.indices?.resize(indexCount)
        
        let halfWidth = width * 0.5
        let halfDepth = depth * 0.5
        let segmentWidth = width / Float(widthSegments)
        let segmentDepth = depth / Float(depthSegments)
        
        // Generate vertices
        var v = 0
        for z in 0...depthSegments {
            for x in 0...widthSegments {
                let xPos = -halfWidth + Float(x) * segmentWidth
                let zPos = -halfDepth + Float(z) * segmentDepth
                
                mesh.setPosition(v, position: Vector3(xPos, 0, zPos))
                mesh.setNormal(v, normal: Vector3(0, 1, 0))
                mesh.setUV(v, uv: Vector2(Float(x) / Float(widthSegments), Float(z) / Float(depthSegments)))
                mesh.setColor(v, color: 0xFFFFFFFF)
                v += 1
            }
        }
        
        // Generate indices with REVERSED winding order
        var idx = 0
        for z in 0..<depthSegments {
            for x in 0..<widthSegments {
                let a = z * (widthSegments + 1) + x
                let b = a + 1
                let c = a + widthSegments + 1
                let d = c + 1
                
                // First triangle (reversed: a,c,b -> a,b,c)
                mesh.indices?.setIndex(idx, value: UInt32(a)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
                
                // Second triangle (reversed: b,c,d -> b,d,c)
                mesh.indices?.setIndex(idx, value: UInt32(b)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(d)); idx += 1
                mesh.indices?.setIndex(idx, value: UInt32(c)); idx += 1
            }
        }
        
        // Generate tangents
        mesh.generateTangents()
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: indexCount))
        return mesh
    }
    
    // Example: Create mesh with custom vertex format
    public static func createCustomFormatExample() -> Mesh {
        let mesh = Mesh()
        
        // Custom format: Position (Vec3) + UV (Vec2) + Tangent (Vec3) + Bitangent (Vec3)
        let vertexSize = MemoryLayout<Vector3>.size + MemoryLayout<Vector2>.size + MemoryLayout<Vector3>.size + MemoryLayout<Vector3>.size
        mesh.initialize(vertexSize: vertexSize, indexFormat: .uint16)
        
        // Define attribute offsets
        let posOffset = 0
        let uvOffset = MemoryLayout<Vector3>.size
        let tangentOffset = MemoryLayout<Vector3>.size + MemoryLayout<Vector2>.size
        let bitangentOffset = MemoryLayout<Vector3>.size + MemoryLayout<Vector2>.size + MemoryLayout<Vector3>.size
        
        // Add attributes for debugging/tooling
        mesh.vertices?.addAttribute(name: "position", type: .vec3, offset: posOffset, size: MemoryLayout<Vector3>.size)
        mesh.vertices?.addAttribute(name: "uv", type: .vec2, offset: uvOffset, size: MemoryLayout<Vector2>.size)
        mesh.vertices?.addAttribute(name: "tangent", type: .vec3, offset: tangentOffset, size: MemoryLayout<Vector3>.size)
        mesh.vertices?.addAttribute(name: "bitangent", type: .vec3, offset: bitangentOffset, size: MemoryLayout<Vector3>.size)
        
        // Create a simple quad with custom format
        mesh.vertices?.resize(4)
        mesh.indices?.resize(6)
        
        // Set vertex data using direct access
        for i in 0..<4 {
            // Position
            var pos = Vector3.zero
            switch i {
            case 0: pos = Vector3(-1, 0, -1)
            case 1: pos = Vector3(1, 0, -1)
            case 2: pos = Vector3(1, 0, 1)
            case 3: pos = Vector3(-1, 0, 1)
            default: break
            }
            mesh.setVertexAttribute(i, attributeOffset: posOffset, value: pos)
            
            // UV
            var uv = Vector2.zero
            switch i {
            case 0: uv = Vector2(0, 0)
            case 1: uv = Vector2(1, 0)
            case 2: uv = Vector2(1, 1)
            case 3: uv = Vector2(0, 1)
            default: break
            }
            mesh.setVertexAttribute(i, attributeOffset: uvOffset, value: uv)
            
            // Tangent & Bitangent (simplified for this example)
            mesh.setVertexAttribute(i, attributeOffset: tangentOffset, value: Vector3(1, 0, 0))
            mesh.setVertexAttribute(i, attributeOffset: bitangentOffset, value: Vector3(0, 0, 1))
        }
        
        // Set indices
        mesh.indices?.setIndex(0, value: 0)
        mesh.indices?.setIndex(1, value: 1)
        mesh.indices?.setIndex(2, value: 2)
        mesh.indices?.setIndex(3, value: 0)
        mesh.indices?.setIndex(4, value: 2)
        mesh.indices?.setIndex(5, value: 3)
        
        mesh.addSubMesh(SubMesh(startIndex: 0, indexCount: 6))
        
        return mesh
    }
}