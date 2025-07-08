import Foundation

public class IndexBuffer {
    public enum IndexFormat {
        case uint16
        case uint32
    }
    
    private var data: Data
    private var indexCount: Int
    private let format: IndexFormat
    
    public var count: Int { return indexCount }
    public var indexFormat: IndexFormat { return format }
    
    public init(format: IndexFormat) {
        self.format = format
        self.indexCount = 0
        self.data = Data()
    }
    
    public func reserve(_ count: Int) {
        let size = getIndexSize()
        let newSize = count * size
        if data.count < newSize {
            data.count = newSize
        }
    }
    
    public func resize(_ count: Int) {
        indexCount = count
        reserve(count)
    }
    
    private func getIndexSize() -> Int {
        switch format {
        case .uint16: return 2
        case .uint32: return 4
        }
    }
    
    public func setIndex(_ index: Int, value: UInt32) {
        guard index < indexCount else { return }
        
        let size = getIndexSize()
        let offset = index * size
        
        switch format {
        case .uint16:
            let val = UInt16(value)
            data.replaceSubrange(offset..<(offset + 2), with: withUnsafeBytes(of: val) { Data($0) })
        case .uint32:
            data.replaceSubrange(offset..<(offset + 4), with: withUnsafeBytes(of: value) { Data($0) })
        }
    }
    
    public func getIndex(_ index: Int) -> UInt32 {
        guard index < indexCount else { return 0 }
        
        let size = getIndexSize()
        let offset = index * size
        
        switch format {
        case .uint16:
            let val = data.subdata(in: offset..<(offset + 2)).withUnsafeBytes { $0.load(as: UInt16.self) }
            return UInt32(val)
        case .uint32:
            return data.subdata(in: offset..<(offset + 4)).withUnsafeBytes { $0.load(as: UInt32.self) }
        }
    }
    
    public func getRawData() -> UnsafeRawPointer {
        return data.withUnsafeBytes { bytes in
            return UnsafeRawPointer(bytes.bindMemory(to: UInt8.self).baseAddress!)
        }
    }
}

extension IndexBuffer {
    public func getData() -> Data {
        return data
    }
    
    public func loadFromData(_ newData: Data) {
        data = newData
        let indexSize = getIndexSize()
        indexCount = data.count / indexSize
    }
}