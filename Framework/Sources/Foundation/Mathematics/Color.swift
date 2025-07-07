public struct Color: Hashable, Codable, Equatable, Sendable {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8
    
    public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public static let white = Color(255, 255, 255)
    public static let black = Color(0, 0, 0)
    public static let red = Color(255, 0, 0)
    public static let green = Color(0, 255, 0)
    public static let blue = Color(0, 0, 255)
    public static let transparent = Color(0, 0, 0, 0)
    
    // Convert to ColorF
    public var toColorF: ColorF {
        ColorF(Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0, Float(a) / 255.0)
    }
}