struct Size3D: Hashable, Codable, Equatable {
    var width: Double
    var height: Double
    var depth: Double
    
    init(_ width: Double, _ height: Double, _ depth: Double) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    init(width: Double, height: Double, depth: Double) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    static let zero = Size3D(0, 0, 0)
    
    // Convert to Size3
    var toSize3: Size3 {
        Size3(Int(width), Int(height), Int(depth))
    }
}