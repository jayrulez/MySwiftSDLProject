struct RectangleD: Hashable, Codable, Equatable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    
    init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(location: Point2D, size: Size2D) {
        self.x = location.x
        self.y = location.y
        self.width = size.width
        self.height = size.height
    }
    
    static let empty = RectangleD(0, 0, 0, 0)
    
    var location: Point2D {
        get { Point2D(x, y) }
        set { x = newValue.x; y = newValue.y }
    }
    
    var size: Size2D {
        get { Size2D(width, height) }
        set { width = newValue.width; height = newValue.height }
    }
    
    var center: Point2D {
        Point2D(x + width / 2, y + height / 2)
    }
    
    var right: Double { x + width }
    var bottom: Double { y + height }
    
    // Convert to Rectangle
    var toRectangle: Rectangle {
        Rectangle(Int(x), Int(y), Int(width), Int(height))
    }
}