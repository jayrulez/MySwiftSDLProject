struct Rectangle: Hashable, Codable, Equatable {
    var x: Int
    var y: Int
    var width: Int
    var height: Int
    
    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(location: Point2, size: Size2) {
        self.x = location.x
        self.y = location.y
        self.width = size.width
        self.height = size.height
    }
    
    static let empty = Rectangle(0, 0, 0, 0)
    
    var location: Point2 {
        get { Point2(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    var size: Size2 {
        get { Size2(width, height) }
        set { width = newValue.width; height = newValue.height }
    }
    
    var center: Point2 {
        Point2(x + width / 2, y + height / 2)
    }
    
    var right: Int { x + width }
    var bottom: Int { y + height }
    
    // Convert to RectangleF
    var toRectangleF: RectangleF {
        RectangleF(Float(x), Float(y), Float(width), Float(height))
    }
}