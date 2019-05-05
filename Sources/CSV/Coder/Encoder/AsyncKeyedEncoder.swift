import Foundation

final class AsyncKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    var codingPath: [CodingKey]
    var encoder: AsyncEncoder
    
    init(path: [CodingKey], encoder: AsyncEncoder) {
        self.codingPath = path
        self.encoder = encoder
    }
    
    func _encode(_ value: [UInt8], for key: K) {
        switch self.encoder.container.section {
        case .header:
            let bytes = Array([[34], key.stringValue.bytes, [34]].joined())
            self.encoder.container.cells.append(bytes)
        case .row:
            let bytes = Array([[34], value, [34]].joined())
            self.encoder.container.cells.append(bytes)
        }
    }
    func _encode(_ value: [UInt8]?, for key: K)throws {
        if let value = value {
            self._encode(value, for: key)
        } else {
            try self.encodeNil(forKey: key)
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
    func encode(_ value: Float, forKey key: K)  throws { self._encode(value.bytes, for: key) }
    func encode(_ value: Int, forKey key: K)    throws { self._encode(value.bytes, for: key) }
    func encode(_ value: String, forKey key: K) throws { self._encode(value.bytes, for: key) }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        let encoder = AsyncEncoder(encodingOptions: self.encoder.encodingOptions, configuration: self.encoder.configuration, onRow: self.encoder.onRow)
        try value.encode(to: encoder)
        self._encode(encoder.container.cells[0], for: key)
    }

    func encodeIfPresent(_ value: Bool?, forKey key: K)   throws {
        let value = value.map(self.encoder.encodingOptions.boolCodingStrategy.bytes(from:))
        try self._encode(value, for: key)
    }
    func encodeIfPresent(_ value: Double?, forKey key: K) throws { try self._encode(value?.bytes, for: key) }
    func encodeIfPresent(_ value: Float?, forKey key: K)  throws { try self._encode(value?.bytes, for: key) }
    func encodeIfPresent(_ value: Int?, forKey key: K)    throws { try self._encode(value?.bytes, for: key) }
    func encodeIfPresent(_ value: String?, forKey key: K) throws { try self._encode(value?.bytes, for: key) }
    func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
        if let value = value {
            try self.encode(value, forKey: key)
        } else {
            try self.encodeNil(forKey: key)
        }
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
