import Foundation

public class VertexBuffer {
    private var data: Data
    private let vertexSize: Int
    private var vertexCount: Int
    private var attributes: [VertexAttribute]
    
    public var count: Int { return vertexCount }
    public var stride: Int { return vertexSize }
    
    public init(vertexSize: Int) {
        self.vertexSize = vertexSize
        self.vertexCount = 0
        self.data = Data()
        self.attributes = []
    }
    
    public func reserve(_ count: Int) {
        let newSize = count * vertexSize
        if data.count < newSize {
            data.count = newSize
        }
    }
    
    public func resize(_ count: Int) {
        vertexCount = count
        reserve(count)
    }
    
    public func addAttribute(name: String, type: AttributeType, offset: Int, size: Int) {
        attributes.append(VertexAttribute(name: name, type: type, offset: offset, size: size))
    }
    
    public func setVertexData<T>(_ vertexIndex: Int, offset: Int, value: T) {
        guard vertexIndex < vertexCount else { return }
        
        let dataOffset = vertexIndex * vertexSize + offset
        let valueData = withUnsafeBytes(of: value) { Data($0) }
        data.replaceSubrange(dataOffset..<(dataOffset + MemoryLayout<T>.size), with: valueData)
    }
    
    public func getVertexData<T>(_ vertexIndex: Int, offset: Int, as type: T.Type) -> T {
        guard vertexIndex < vertexCount else { return getZeroValue(for: type) }
        
        let dataOffset = vertexIndex * vertexSize + offset
        return data.subdata(in: dataOffset..<(dataOffset + MemoryLayout<T>.size)).withUnsafeBytes { 
            $0.load(as: T.self) 
        }
    }
    
    private func getZeroValue<T>(for type: T.Type) -> T {
        // This is a simplified approach - in practice you might want to handle this differently
        let zeroData = Data(count: MemoryLayout<T>.size)
        return zeroData.withUnsafeBytes { $0.load(as: T.self) }
    }
    
    public func getRawData() -> UnsafeRawPointer {
        return data.withUnsafeBytes { bytes in
            return UnsafeRawPointer(bytes.bindMemory(to: UInt8.self).baseAddress!)
        }
    }
}

extension VertexBuffer {
    public func getData() -> Data {
        return data
    }
    
    public func loadFromData(_ newData: Data) {
        data = newData
        vertexCount = data.count / vertexSize
    }
    
    public func getAttributes() -> [VertexAttribute] {
        return attributes
    }
}