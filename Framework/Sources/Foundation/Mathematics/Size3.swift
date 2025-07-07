public struct Size3: Hashable, Codable, Equatable, Sendable {
    public var width: Int
    public var height: Int
    public var depth: Int
    
    public init(_ width: Int, _ height: Int, _ depth: Int) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    public init(width: Int, height: Int, depth: Int) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    public static let zero = Size3(0, 0, 0)
    
    // Convert to Vector3
    public var toVector3: Vector3 {
        Vector3(Float(width), Float(height), Float(depth))
    }
}