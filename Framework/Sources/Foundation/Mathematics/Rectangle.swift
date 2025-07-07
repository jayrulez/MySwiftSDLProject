public struct Rectangle: Hashable, Codable, Equatable, Sendable {
    public var x: Int
    public var y: Int
    public var width: Int
    public var height: Int
    
    public init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(location: Point2, size: Size2) {
        self.x = location.x
        self.y = location.y
        self.width = size.width
        self.height = size.height
    }
    
    public static let empty = Rectangle(0, 0, 0, 0)
    
    public var location: Point2 {
        get { Point2(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    public var size: Size2 {
        get { Size2(width, height) }
        set { width = newValue.width; height = newValue.height }
    }
    
    public var center: Point2 {
        Point2(x + width / 2, y + height / 2)
    }
    
    public var right: Int { x + width }
    public var bottom: Int { y + height }
    
    // Convert to RectangleF
    public var toRectangleF: RectangleF {
        RectangleF(Float(x), Float(y), Float(width), Float(height))
    }
}