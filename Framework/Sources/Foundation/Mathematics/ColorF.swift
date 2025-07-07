public struct ColorF: Hashable, Codable, Equatable, Sendable {
    public var r: Float
    public var g: Float
    public var b: Float
    public var a: Float
    
    public init(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(r: Float, g: Float, b: Float, a: Float = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public static let white = ColorF(1, 1, 1)
    public static let black = ColorF(0, 0, 0)
    public static let red = ColorF(1, 0, 0)
    public static let green = ColorF(0, 1, 0)
    public static let blue = ColorF(0, 0, 1)
    public static let transparent = ColorF(0, 0, 0, 0)
    
    // Convert to Color
    public var toColor: Color {
        Color(UInt8(r * 255), UInt8(g * 255), UInt8(b * 255), UInt8(a * 255))
    }
}