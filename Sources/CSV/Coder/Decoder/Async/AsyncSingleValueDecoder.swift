internal final class _AsyncSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var decoder: _CSVAsyncDecoder
    var bytes: [UInt8]

    internal init(path: [CodingKey], decoder: _CSVAsyncDecoder)throws {
        self.decoder = decoder
        self.codingPath = path

        guard case let .singleValue(bytes) = decoder.data else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: path,
                debugDescription: "Single value required to create a created a single value decoder"
            ))
        }
        self.bytes = bytes
    }

    func decodeNil() -> Bool {
        return self.decoder.decodingOptions.nilCodingStrategy.isNull(self.bytes)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let bool = self.decoder.decodingOptions.boolCodingStrategy.bool(from: self.bytes) else {
            throw DecodingError.typeMismatch(
                Bool.self,
                .init(codingPath: self.codingPath, debugDescription: "Cannot decode `Bool` from bytes `\(bytes)`")
            )
        }
        return bool
    }

    func decode(_ type: String.Type) throws -> String {
        return String(decoding: self.bytes, as: UTF8.self)
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let double = self.bytes.double else {
            throw DecodingError.typeMismatch(type, .init(
                codingPath: self.codingPath,
                debugDescription: "Cannot convert bytes `\(self.bytes)` to Double"
            ))
        }

        return double
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard let float = self.bytes.float else {
            throw DecodingError.typeMismatch(type, .init(
                codingPath: self.codingPath,
                debugDescription: "Cannot convert bytes `\(self.bytes)` to Float"
            ))
        }

        return float
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let int = self.bytes.int else {
            throw DecodingError.typeMismatch(type, .init(
                codingPath: self.codingPath,
                debugDescription: "Cannot convert bytes `\(self.bytes)` to Int"
            ))
        }

        return int
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _CSVAsyncDecoder(
            decoding: self.decoder.decoding,
            path: self.codingPath,
            data: .singleValue(self.bytes),
            decodingOptions: self.decoder.decodingOptions,
            onInstance: self.decoder.onInstance
        )

        let t = try T.init(from: decoder)
        return t
    }
}
