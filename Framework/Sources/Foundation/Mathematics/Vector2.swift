public struct Vector2<T: Numeric & Comparable>: Equatable, Hashable where T : Hashable {
    public var x: T
    public var y: T
    
    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }
    
    public static func ==(lhs: Vector2<T>, rhs: Vector2<T>) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}