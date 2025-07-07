public struct RectangleF: Hashable, Codable, Equatable, Sendable {
    public var x: Float
    public var y: Float
    public var width: Float
    public var height: Float
    
    public init(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(location: Point2F, size: Vector2) {
        self.x = location.x
        self.y = location.y
        self.width = size.x
        self.height = size.y
    }
    
    public static let empty = RectangleF(0, 0, 0, 0)
    
    public var location: Point2F {
        get { Point2F(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    public var size: Vector2 {
        get { Vector2(width, height) }
        set { width = newValue.x; height = newValue.y }
    }
    
    public var center: Point2F {
        Point2F(x + width / 2, y + height / 2)
    }
    
    public var right: Float { x + width }
    public var bottom: Float { y + height }
    
    // Convert to Rectangle
    public var toRectangle: Rectangle {
        Rectangle(Int(x), Int(y), Int(width), Int(height))
    }
}