public struct SubMesh {
    public let startIndex: Int
    public let indexCount: Int
    public let materialIndex: Int
    public let primitiveType: PrimitiveType
    
    public init(startIndex: Int, indexCount: Int, materialIndex: Int = 0, primitiveType: PrimitiveType = .triangles) {
        self.startIndex = startIndex
        self.indexCount = indexCount
        self.materialIndex = materialIndex
        self.primitiveType = primitiveType
    }
}