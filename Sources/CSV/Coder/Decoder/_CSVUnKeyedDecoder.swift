import Foundation

final class _CSVUnkeyedDecoder: UnkeyedDecodingContainer {
    let codingPath: [CodingKey]
    let count: Int?
    var currentIndex: Int
    let columns: [String: [String?]]
    let next: () -> [String: String?]?
    
    init(columns: [String: [String?]], path: CodingPath = []) {
        self.codingPath = path
        self.count = columns.count
        self.currentIndex = 0
        self.columns = columns
        self.next = columns.makeRows()
    }
    
    var isAtEnd: Bool {
        return currentIndex < (count ?? 0)
    }
    
    func pop()throws -> [String: String?] {
        guard let row = next() else {
            throw DecodingError.valueNotFound([String: String?].self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "No row exists at the current index"))
        }
        self.currentIndex += 1
        return row
    }
    
    func decodeNil() throws -> Bool {
        return self.isAtEnd
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(type) value from string array"))
    }
    
    func decode(_ type: String.Type) throws -> String {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(type) value from string array"))
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(type) value from string array"))
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(type) value from string array"))
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(type) value from string array"))
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = try _CSVDecoder(row: self.pop(), path: self.codingPath)
        return try T(from: decoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.valueNotFound(
            KeyedDecodingContainer<NestedKey>.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot create nested container from CSV Unkeyed Container"
            )
        )
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(
            UnkeyedDecodingContainer.self,
            DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot create nested unkeyed container from CSV Unkeyed Container"
            )
        )
    }
    
    func superDecoder() throws -> Decoder {
        throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot create super decoder from CSV Unkeyed Decoder"))
    }
}

extension Dictionary where Key == String, Value == Array<String?> {
    public func makeRows() -> () -> [String: String?]? {
        var rowIndex = 1
        
        func next() -> [String: String?]? {
            defer { rowIndex += 1 }
            guard let first = self.first else { return nil }
            guard rowIndex < first.value.count else { return nil }
            return self.mapValues { $0[rowIndex] }
        }
        
        return next
    }
}
