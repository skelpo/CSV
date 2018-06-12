import Foundation
import Core

final class _CSVUnkeyedDecoder: UnkeyedDecodingContainer {
    let codingPath: [CodingKey]
    let count: Int?
    var currentIndex: Int

    let decoder: _CSVDecoder
    
    init(decoder: _CSVDecoder, path: CodingPath = []) {
        self.codingPath = path
        self.count = nil
        self.currentIndex = 0
        self.decoder = decoder
        self.decoder.container.incremetRow()
    }
    
    var isAtEnd: Bool {
        return self.decoder.container.row == nil
    }
    
    func error<T>(for type: T.Type) -> Error {
        return DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get \(T.self) value from string array"))
    }
    
    func decodeNil() throws -> Bool {
        return self.isAtEnd
    }
    
    func decode(_ type: Bool.Type) throws -> Bool { throw self.error(for: type) }
    func decode(_ type: String.Type) throws -> String { throw self.error(for: type) }
    func decode(_ type: Double.Type) throws -> Double { throw self.error(for: type) }
    func decode(_ type: Float.Type) throws -> Float { throw self.error(for: type) }
    func decode(_ type: Int.Type) throws -> Int { throw self.error(for: type) }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer {
            self.currentIndex += 1
            self.decoder.container.incremetRow()
        }
        return try T(from: self.decoder)
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
