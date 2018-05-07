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
    
    func encodeNil(forKey key: K) throws {
        self.container.data.append(.comma)
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        self.container.data.append(contentsOf: self.boolEncoding.convert(value) + [.comma])
    }
    
    func encode(_ value: String, forKey key: K) throws {
        guard let string = value.data(using: self.stringEncoding) else {
            throw EncodingError.unableToConvert(value: value, at: self.codingPath, encoding: self.stringEncoding)
        }
        self.container.data.append(contentsOf: string + [.comma])
    }
    
    func encode(_ value: Double, forKey key: K) throws {
        self.container.data.append(contentsOf: String(value).data + [.comma])
    }
    
    func encode(_ value: Float, forKey key: K) throws {
        self.container.data.append(contentsOf: String(value).data + [.comma])
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        self.container.data.append(contentsOf: String(value).data + [.comma])
    }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        let encoder = _CSVEncoder(data: DataContainer(), path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        try value.encode(to: encoder)
        self.container.data.append(contentsOf: encoder.data.data)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CSVKeyedEncoder<NestedKey>(container: self.container, path: self.codingPath + [key], boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(data: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _CSVEncoder(data: self.container, path: self.codingPath + [key], boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
}
