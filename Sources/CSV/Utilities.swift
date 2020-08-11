// MARK: - String <-> Bytes conversion
extension CustomStringConvertible {

    /// Converts the value's string description to its byte representation.
    var bytes: [UInt8] {
        return Array(self.description.utf8)
    }
}

extension String {

    /// Creats a new `String` instance from an array of bytes.
    ///
    /// - Parameter bytes: The byte array that will be the new string value.
    init(_ bytes: [UInt8]) {
        self = String(decoding: bytes, as: UTF8.self)
    }
}

extension Array where Element == UInt8 {

    /// Escapes raw escape chraacters in a byte array.
    ///
    /// The characters are escaped by each escape charcter in the array being replaced with 2 escape charcters, so a string like this:
    ///
    ///     "\o/"
    ///
    /// If escaped with the `\` chracter, would become:
    ///
    ///     "\\o/"
    ///
    /// - Parameter character: The byte that represents the character to escape.
    /// - Returns: The bytes of the string, with each raw escaped character being escaped.
    func escaping(_ character: UInt8?) -> [UInt8] {
        guard let code = character else {
            return self
        }

        let contents = self.contains(code) ?
            Array(self.split(separator: code, omittingEmptySubsequences: false).joined(separator: [code, code])) :
            self
        return Array([[code], contents, [code]].joined())
    }
}

// MARK: - Coding Key Interactions
extension Dictionary where Key == String {

    /// Extracts the value from a dictinary, using a `CodingKey` for the key.
    ///
    /// - Parameter key: The coding key to use as the key in the dictionary.
    /// - Returns: The  value for the key passed in.
    /// - Throws: `DecodingError.valueNotFound` if the value for the given key is missing,
    func value(for key: CodingKey)throws -> Value {
        guard let value = self[key.stringValue] else {
            throw DecodingError.valueNotFound(Value.self, .init(
                codingPath: [key],
                debugDescription: "No value found for key '\(key.stringValue)'"
            ))
        }
        return value
    }
}
