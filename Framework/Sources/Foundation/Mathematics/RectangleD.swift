public struct RectangleD: Hashable, Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    
    public init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(location: Point2D, size: Size2D) {
        self.x = location.x
        self.y = location.y
        self.width = size.width
        self.height = size.height
    }
    
    public static let empty = RectangleD(0, 0, 0, 0)
    
    public var location: Point2D {
        get { Point2D(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    public var size: Size2D {
        get { Size2D(width, height) }
        set { width = newValue.width; height = newValue.height }
    }
    
    public var center: Point2D {
        Point2D(x + width / 2, y + height / 2)
    }
    
    public var right: Double { x + width }
    public var bottom: Double { y + height }
    
    // Convert to Rectangle
    public var toRectangle: Rectangle {
        Rectangle(Int(x), Int(y), Int(width), Int(height))
    }
}