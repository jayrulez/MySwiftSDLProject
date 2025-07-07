struct RectangleF: Hashable, Codable, Equatable {
    var x: Float
    var y: Float
    var width: Float
    var height: Float
    
    init(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(location: Point2F, size: Vector2) {
        self.x = location.x
        self.y = location.y
        self.width = size.x
        self.height = size.y
    }
    
    static let empty = RectangleF(0, 0, 0, 0)
    
    var location: Point2F {
        get { Point2F(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    var size: Vector2 {
        get { Vector2(width, height) }
        set { width = newValue.x; height = newValue.y }
    }
    
    var center: Point2F {
        Point2F(x + width / 2, y + height / 2)
    }
    
    var right: Float { x + width }
    var bottom: Float { y + height }
    
    // Convert to Rectangle
    var toRectangle: Rectangle {
        Rectangle(Int(x), Int(y), Int(width), Int(height))
    }
}