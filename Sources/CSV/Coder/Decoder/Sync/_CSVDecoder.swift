import Foundation

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let userInfo: [CodingUserInfoKey : Any]
    var codingPath: [CodingKey]
    
    let container: DecoderDataContainer
    let decodingOptions: CSVCodingOptions
    
    init(csv: [UInt8], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], decodingOptions: CSVCodingOptions)throws {
        self.codingPath = path
        self.userInfo = info
        self.container = try DecoderDataContainer(data: csv)
        self.decodingOptions = decodingOptions
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard self.container.row != nil else {
            throw DecodingError.typeMismatch(
                [String: String?].self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get CSV row as expected format '[String: String?]'"
                )
            )
        }
        let container = _CSVKeyedDecoder<Key>(decoder: self)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return _CSVUnkeyedDecoder(decoder: self, path: self.codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _CSVSingleValueDecoder(decoder: self)
    }
    
    func decode<T>(_ type: T.Type, from data: Data)throws -> [T] where T: Decodable {
        let decoder = try _CSVDecoder(csv: Array(data), decodingOptions: self.decodingOptions)
        return try Array<T>(from: decoder)
    }
}
