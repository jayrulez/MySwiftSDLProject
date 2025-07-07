struct Size3: Hashable, Codable, Equatable {
    var width: Int
    var height: Int
    var depth: Int
    
    init(_ width: Int, _ height: Int, _ depth: Int) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    init(width: Int, height: Int, depth: Int) {
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    static let zero = Size3(0, 0, 0)
    
    // Convert to Vector3
    var toVector3: Vector3 {
        Vector3(Float(width), Float(height), Float(depth))
    }
}