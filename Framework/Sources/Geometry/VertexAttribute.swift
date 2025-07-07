public struct VertexAttribute {
    public let name: String
    public let type: AttributeType
    public let offset: Int
    public let size: Int
    
    public init(name: String, type: AttributeType, offset: Int, size: Int) {
        self.name = name
        self.type = type
        self.offset = offset
        self.size = size
    }
}