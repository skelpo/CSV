import Foundation

final class _CSVEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let data: DataContainer
    let boolEncoding: BoolEncodingStrategy
    let stringEncoding: String.Encoding
    
    init(
        data: DataContainer,
        path: CodingPath = [],
        info: [CodingUserInfoKey : Any] = [:],
        boolEncoding: BoolEncodingStrategy = .toString,
        stringEncoding: String.Encoding = .utf8
    ) {
        self.codingPath = path
        self.userInfo = info
        self.data = data
        self.boolEncoding = boolEncoding
        self.stringEncoding = stringEncoding
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = _CSVKeyedEncoder<Key>(container: self.data, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.data, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return _CSVSingleValueEncoder(container: self.data, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    static func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        let encoder = _CSVEncoder(data: DataContainer())
        try objects.encode(to: encoder)
        return encoder.data.data
    }
}

final class DataContainer {
    var data: Data
    var titlesCreated: Bool
    
    init(data: Data = Data()) {
        self.data = data
        self.titlesCreated = false
    }
}
