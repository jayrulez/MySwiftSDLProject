struct Color: Hashable, Codable, Equatable {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    static let white = Color(255, 255, 255)
    static let black = Color(0, 0, 0)
    static let red = Color(255, 0, 0)
    static let green = Color(0, 255, 0)
    static let blue = Color(0, 0, 255)
    static let transparent = Color(0, 0, 0, 0)
    
    // Convert to ColorF
    var toColorF: ColorF {
        ColorF(Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0, Float(a) / 255.0)
    }
}