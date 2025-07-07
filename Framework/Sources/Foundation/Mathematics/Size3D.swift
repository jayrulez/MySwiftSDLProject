public struct Size3D: Hashable, Codable, Equatable, Sendable {
    public var width: Double
    public var height: Double
    public var depth: Double
    
    public init(_ width: Double, _ height: Double, _ depth: Double) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    public init(width: Double, height: Double, depth: Double) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    public static let zero = Size3D(0, 0, 0)
    
    // Convert to Size3
    public var toSize3: Size3 {
        Size3(Int(width), Int(height), Int(depth))
    }
}