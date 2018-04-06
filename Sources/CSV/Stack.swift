import Bits
import Foundation

public struct Stack: ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
    public typealias ArrayLiteralElement = Byte
    
    var store: Data
    
    public init(arrayLiteral elements: Byte...) {
        self.store = Data(elements)
    }
    
    public init(stringLiteral value: String) {
        self.store = Data(value.utf8)
    }
    
    public var empty: Bool {
        return self.store.isEmpty
    }
    
    public mutating func push(_ byte: Byte) {
        self.store.append(byte)
    }
    
    public mutating func release() -> String {
        defer { store.removeAll() }
        return String(data: store, encoding: .utf8) ?? ""
    }
}

extension Stack: RandomAccessCollection {
    public typealias Index = Data.Index
    public typealias Element = Data.Element
    public typealias SubSequence = Data.SubSequence
    public typealias Indices = Data.Indices
    
    public var startIndex: Data.Index {
        return self.store.startIndex
    }
    
    public var endIndex: Data.Index {
        return self.store.endIndex
    }
    
    public func index(before i: Data.Index) -> Data.Index {
        return self.store.index(before: i)
    }
    
    public func index(after i: Data.Index) -> Data.Index {
        return self.store.index(after: i)
    }
    
    public subscript(position: Data.Index) -> Data.Element {
        return self.store[position]
    }
}
