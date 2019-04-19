internal final class AsyncKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    internal var codingPath: [CodingKey]
    internal var decoder: AsyncDecoder
    private var data: [String: [UInt8]]

    internal init(path: [CodingKey], decoder: AsyncDecoder)throws {
        self.decoder = decoder
        self.codingPath = path

        guard case let .keyedValues(data) = decoder.data else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: path,
                debugDescription: "Keyed data required to create a created a keyed decoder"
            ))
        }
        self.data = data
    }

    public var allKeys: [K] {
        return self.data.keys.compactMap(K.init)
    }

    private func bytes<T>(for key: K, type: T.Type)throws -> [UInt8] {
        guard let bytes = self.data[key.stringValue] else {
            throw DecodingError.valueNotFound(
                T.self,
                .init(codingPath: self.codingPath, debugDescription: "No value for key `\(key.stringValue)` found in row")
            )
        }

        return bytes
    }

    public func contains(_ key: K) -> Bool {
        return self.data.keys.contains(key.stringValue)
    }

    public func decodeNil(forKey key: K) throws -> Bool {
        guard let bytes = self.data[key.stringValue] else { return true }
        return self.decoder.decodingOptions.nilCodingStrategy.isNull(bytes)
    }

    public func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let bytes = try self.bytes(for: key, type: Bool.self)
        guard let bool = self.decoder.decodingOptions.boolCodingStrategy.bool(from: bytes) else {
            throw DecodingError.typeMismatch(
                Bool.self,
                .init(codingPath: self.codingPath, debugDescription: """
                    Cannot get Bool from bytes `\(bytes)` using bool decoding strategy \
                    `\(self.decoder.decodingOptions.boolCodingStrategy)`
                    """
                )
            )
        }

        return bool
    }

    public func decode(_ type: String.Type, forKey key: K) throws -> String {
        let bytes = try self.bytes(for: key, type: type)
        return String(decoding: bytes, as: UTF8.self)
    }

    public func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        let bytes = try self.bytes(for: key, type: type)
        guard let double = bytes.double else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(codingPath: self.codingPath, debugDescription: "Cannot convert bytes `\(bytes)` to type `Double`")
            )
        }

        return double
    }

    public func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        let bytes = try self.bytes(for: key, type: type)
        guard let float = bytes.float else {
            throw DecodingError.typeMismatch(
                Float.self,
                .init(codingPath: self.codingPath, debugDescription: "Cannot convert bytes `\(bytes)` to type `Float`")
            )
        }

        return float
    }

    public func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        let bytes = try self.bytes(for: key, type: type)
        guard let int = bytes.int else {
            throw DecodingError.typeMismatch(
                Int.self,
                .init(codingPath: self.codingPath, debugDescription: "Cannot convert bytes `\(bytes)` to type `Int`")
            )
        }

        return int
    }

    public func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        let bytes = try self.bytes(for: key, type: type)
        let decoder = AsyncDecoder(
            decoding: self.decoder.decoding,
            path: self.codingPath + [key],
            data: .singleValue(bytes),
            decodingOptions: self.decoder.decodingOptions,
            onInstance: self.decoder.onInstance
        )

        let t = try T.init(from: decoder)
        return t
    }

    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K)
        throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey
    {
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "CSV decoding does not support nested keyed decoders"
        )
    }

    public func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "CSV decoding does not support nested unkeyed decoders"
        )
    }

    public func superDecoder() throws -> Decoder {
        return self.decoder
    }

    public func superDecoder(forKey key: K) throws -> Decoder {
        return self.decoder
    }
}
