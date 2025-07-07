public struct Size2: Hashable, Codable, Equatable, Sendable {
    public var width: Int
    public var height: Int
    
    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public static let zero = Size2(0, 0)
    
    // Convert to Vector2
    public var toVector2: Vector2 {
        Vector2(Float(width), Float(height))
    }
}