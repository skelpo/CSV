import Foundation

// MARK: - String <-> Bytes conversion
extension CustomStringConvertible {
    var bytes: [UInt8] {
        return Array(self.description.utf8)
    }
}

extension String {
    init(_ bytes: [UInt8]) {
        self = String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - Coding Key Interactions
extension Dictionary where Key == String {
    func value(for key: CodingKey)throws -> Value {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context.init(codingPath: [key], debugDescription: "No value found for key '\(key.stringValue)'"))
        }
        return value
    }
}

extension UInt8: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = UInt8(ascii: value)
    }
}

extension Array: ExpressibleByUnicodeScalarLiteral where Element == UInt8 {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = [UInt8(ascii: value)]
    }
}

extension Array: ExpressibleByExtendedGraphemeClusterLiteral where Element == UInt8 {
    public init(extendedGraphemeClusterLiteral value: Character) {
        self = value.unicodeScalars.map(UInt8.init(ascii:))
    }
}

extension Array: ExpressibleByStringLiteral where Element == UInt8 {
    public init(stringLiteral value: String) {
        self = value.unicodeScalars.map(UInt8.init(ascii:))
    }
}
