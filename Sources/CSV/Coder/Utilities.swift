import Foundation
import Core

// MARK: - String <-> Bytes conversion
extension CustomStringConvertible {
    var bytes: Bytes {
        return Array(self.description.utf8)
    }
}

extension String {
    init(_ bytes: Bytes)throws {
        guard let string = String(bytes: bytes, encoding: .utf8) else {
            throw CoreError(identifier: "dataToString", reason: "Converting byte array to string using UTF-8 encoding failed")
        }
        self = string
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

// MARK: - Dictionary Data Organization
extension Dictionary where Key == String, Value: Collection, Value.Element: OptionalType, Value.Index == Int {
    public func makeRows() -> () -> [String: Value.Element.WrappedType]? {
        guard let columnCount = self.first?.value.count else { return { return nil } }
        var rowIndex = 0
        
        func next() -> [String: Value.Element.WrappedType]? {
            defer { rowIndex += 1 }
            guard rowIndex < columnCount else { return nil }
            return self.reduce(into: [:]) { row, cell in
                if let value = cell.value[rowIndex].wrapped {
                    row![cell.key] = value
                }
            }
        }
        
        return next
    }
}
