public struct Size2D: Hashable, Codable, Equatable, Sendable {
    public var width: Double
    public var height: Double
    
    public init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public static let zero = Size2D(0, 0)
    
    // Convert to Size2
    public var toSize2: Size2 {
        Size2(Int(width), Int(height))
    }
}