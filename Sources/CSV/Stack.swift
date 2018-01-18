import Bits

internal struct Stack: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Byte
    
    var store: Bytes
    
    init(arrayLiteral elements: Byte...) {
        self.store = elements
    }
    
    mutating func push(_ byte: Byte) {
        self.store.append(byte)
    }
    
    mutating func release() -> String {
        defer { store = [] }
        return store.makeString()
    }
}

func ==(lhs: Stack, rhs: [Byte]) -> Bool {
    return lhs.store == rhs
}
