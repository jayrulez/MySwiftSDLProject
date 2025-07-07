struct Size2: Hashable, Codable, Equatable {
    var width: Int
    var height: Int
    
    init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    static let zero = Size2(0, 0)
    
    // Convert to Vector2
    var toVector2: Vector2 {
        Vector2(Float(width), Float(height))
    }
}