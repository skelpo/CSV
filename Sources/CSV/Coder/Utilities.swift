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

// MARK: - Swift 4.2 Method Implementations
extension RangeReplaceableCollection where Self: MutableCollection {
    
    /// Removes from the collection all elements that satisfy the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be removed from the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @_inlineable
    public mutating func removeAll(
        where predicate: (Element) throws -> Bool
    ) rethrows {
        if var i = try index(where: predicate) {
            var j = index(after: i)
            while j != endIndex {
                if try !predicate(self[j]) {
                    swapAt(i, j)
                    formIndex(after: &i)
                }
                formIndex(after: &j)
            }
            removeSubrange(i...)
        }
    }
}
