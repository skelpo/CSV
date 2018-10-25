extension EncodingError {
    static func unableToConvert<T>(value: T, at path: CodingPath, encoding: String.Encoding = .utf8) -> EncodingError {
        return EncodingError.invalidValue(
            value,
            EncodingError.Context(
                codingPath: path,
                debugDescription: "Cannot convert \(T.self) value to data using \(encoding) encoding"
            )
        )
    }
}
