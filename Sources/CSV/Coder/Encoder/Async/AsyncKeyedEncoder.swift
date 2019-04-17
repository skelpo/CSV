import Foundation

final class AsyncKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    var codingPath: [CodingKey]
    var encoder: AsyncEncoder
    
    init(path: CodingPath, encoder: AsyncEncoder) {
        self.codingPath = path
        self.encoder = encoder
    }
    
    func _encode(_ value: [UInt8], for key: K) {
        switch self.encoder.container.section {
        case .header: self.encoder.container.cells.append(key.stringValue.bytes)
        case .row: self.encoder.container.cells.append(value)
        }
    }
    
    func encodeNil(forKey key: K) throws {
        let value = self.encoder.encodingOptions.nilCodingStrategy.bytes()
        self._encode(value, for: key)
    }
    func encode(_ value: Bool, forKey key: K) throws {
        let value = self.encoder.encodingOptions.boolCodingStrategy.bytes(from: value)
        self._encode(value, for: key)
    }
    func encode(_ value: Double, forKey key: K) throws { self._encode(value.bytes, for: key) }
    func encode(_ value: Float, forKey key: K) throws { self._encode(value.bytes, for: key) }
    func encode(_ value: Int, forKey key: K) throws { self._encode(value.bytes, for: key) }
    func encode(_ value: String, forKey key: K) throws { self._encode(value.bytes, for: key) }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        let encoder = AsyncEncoder(encodingOptions: self.encoder.encodingOptions, onRow: self.encoder.onRow)
        try value.encode(to: encoder)
        self._encode(encoder.container.cells[0], for: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        let container = AsyncKeyedEncoder<NestedKey>(path: self.codingPath + [key], encoder: self.encoder)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return AsyncUnkeyedEncoder(encoder: self.encoder)
    }
    
    func superEncoder() -> Encoder {
        return self.encoder
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return encoder
    }
}
