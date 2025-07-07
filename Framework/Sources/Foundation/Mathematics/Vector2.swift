import Foundation

// MARK: - Vector Types

public struct Vector2: Hashable, Codable, Equatable, Sendable {
    public var x: Float
    public var y: Float
    
    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Vector2(0, 0)
    public static let one = Vector2(1, 1)
    public static let unitX = Vector2(1, 0)
    public static let unitY = Vector2(0, 1)
    
    public var length: Float {
        sqrt(x * x + y * y)
    }
    
    public var lengthSquared: Float {
        x * x + y * y
    }
    
    public var normalized: Vector2 {
        let len = length
        return len > 0 ? Vector2(x / len, y / len) : Vector2.zero
    }
    
    // Convert to Size2
    public var toSize2: Size2 {
        Size2(Int(x), Int(y))
    }
    
    // Convert to Point2
    public var toPoint: Point2 {
        Point2(Int(x), Int(y))
    }
}

// MARK: - Vector Operations Extensions

public extension Vector2 {
    static func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func *(lhs: Vector2, rhs: Float) -> Vector2 {
        Vector2(lhs.x * rhs, lhs.y * rhs)
    }
    
    static func *(lhs: Float, rhs: Vector2) -> Vector2 {
        Vector2(lhs * rhs.x, lhs * rhs.y)
    }
    
    static func /(lhs: Vector2, rhs: Float) -> Vector2 {
        Vector2(lhs.x / rhs, lhs.y / rhs)
    }
    
    static func dot(_ lhs: Vector2, _ rhs: Vector2) -> Float {
        lhs.x * rhs.x + lhs.y * rhs.y
    }
    
    static func distance(_ lhs: Vector2, _ rhs: Vector2) -> Float {
        (lhs - rhs).length
    }
    
    static func lerp(_ start: Vector2, _ end: Vector2, _ t: Float) -> Vector2 {
        start + (end - start) * t
    }
}