struct Size2D: Hashable, Codable, Equatable {
    var width: Double
    var height: Double
    
    init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    static let zero = Size2D(0, 0)
    
    // Convert to Size2
    var toSize2: Size2 {
        Size2(Int(width), Int(height))
    }
}