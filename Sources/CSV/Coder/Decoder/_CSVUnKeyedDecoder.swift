import Foundation
import Core

final class _CSVUnkeyedDecoder: UnkeyedDecodingContainer {
    let codingPath: [CodingKey]
    let count: Int?
    var currentIndex: Int
    
    let stringDecoding: String.Encoding
    let columns: [String: [Data?]]
    let next: () -> [String: Data]?
    
    init(columns: [String: [Data?]], path: CodingPath = [], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.count = columns.first?.value.count
        self.currentIndex = 0
        self.stringDecoding = stringDecoding
        self.columns = columns
        self.next = columns.makeRows()
    }
    
    var isAtEnd: Bool {
        return self.currentIndex >= (self.count ?? 0)
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
        defer { self.currentIndex += 1 }
        guard let row = next() else {
            throw DecodingError.valueNotFound([String: String?].self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "No row exists at the current index"))
        }
        let decoder = _CSVDecoder(row: row, path: self.codingPath, stringDecoding: stringDecoding)
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

extension Dictionary where Key == String, Value: Collection, Value.Element: OptionalType, Value.Index == Int {
    public func makeRows() -> () -> [String: Value.Element.WrappedType]? {
        guard let columnCount = self.first?.value.count else { return { return nil } }
        var rowIndex = 0
        
        func next() -> [String: Value.Element.WrappedType]? {
            defer { rowIndex += 1 }
            guard rowIndex < columnCount else { return nil }
            return self.mapValues { $0[rowIndex] }.reduce(into: [:]) { if let value = $1.value.wrapped { $0![$1.key] = value } }
        }
        
        return next
    }
}
