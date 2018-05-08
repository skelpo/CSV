import Foundation

final class _CSVKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    var codingPath: [CodingKey]
    let container: DataContainer
    let boolEncoding: BoolEncodingStrategy
    let stringEncoding: String.Encoding
    
    init(container: DataContainer, path: CodingPath, boolEncoding: BoolEncodingStrategy, stringEncoding: String.Encoding) {
        self.container = container
        self.codingPath = path
        self.boolEncoding = boolEncoding
        self.stringEncoding = stringEncoding
    }
    
    func titleEncode(for key: K, converter: ()throws -> Data)rethrows {
        if self.container.titlesCreated {
            try self.container.data.append(contentsOf: converter() + [.comma])
        } else {
            let lines = self.container.data.split(separator: .newLine)
            let headers = lines.first == nil ? Data() : lines.first! + [.comma]
            let body = lines.last == nil ? Data() : lines.last! + [.comma]
            try self.container.data = (headers + key.stringValue.data) + [.newLine] + (body + converter())
        }
    }
    
    func encodeNil(forKey key: K) throws { self.titleEncode(for: key) { Data() } }
    func encode(_ value: Bool, forKey key: K) throws { self.titleEncode(for: key) { self.boolEncoding.convert(value) } }
    func encode(_ value: Double, forKey key: K) throws { self.titleEncode(for: key) { String(value).data } }
    func encode(_ value: Float, forKey key: K) throws { self.titleEncode(for: key) { String(value).data } }
    func encode(_ value: Int, forKey key: K) throws { self.titleEncode(for: key) { String(value).data } }
    
    func encode(_ value: String, forKey key: K) throws {
        try self.titleEncode(for: key) {
            guard let string = value.data(using: self.stringEncoding) else {
                throw EncodingError.unableToConvert(value: value, at: self.codingPath, encoding: self.stringEncoding)
            }
            return string
        }
    }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        try self.titleEncode(for: key) {
            let encoder = _CSVEncoder(data: DataContainer(titles: true), path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
            try value.encode(to: encoder)
            return encoder.data.data
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CSVKeyedEncoder<NestedKey>(container: self.container, path: self.codingPath + [key], boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(data: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _CSVEncoder(data: self.container, path: self.codingPath + [key], boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
}
