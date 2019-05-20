import Foundation

/// The type where an instance can be represented by an array of bytes (`UInt8`).
public protocol BytesRepresentable {

    /// The bytes that represent the given instance of `Self`.
    var bytes: [UInt8] { get }
}

/// A `Collection` type that contains keyed values.
///
/// This protocol acts as an abstraction over `Dictionary` for the `Serializer` type. It is mostly
/// for testing purposes but you can also conform your own types if you want.
public protocol KeyedCollection: Collection where Self.Element == (key: Key, value: Value) {

    /// The type of a key for a given value.
    associatedtype Key: Hashable

    /// The collection type for a list of the collection's keys.
    associatedtype Keys: Collection where Keys.Element == Key

    /// The type of a value.
    associatedtype Value

    /// The collection type for a list of the collection's values.
    associatedtype Values: Collection where Values.Element == Value

    /// All the collection's keyes.
    var keys: Keys { get }

    /// All the collection's values.
    var values: Values { get }
}

extension String: BytesRepresentable {

    /// The string's UTF-8 view converted to an `Array`.
    public var bytes: [UInt8] {
        return Array(self.utf8)
    }
}

extension Array: BytesRepresentable where Element == UInt8 {

    /// Returns `Self`.
    public var bytes: [UInt8] {
        return self
    }
}

extension Optional: BytesRepresentable where Wrapped: BytesRepresentable {

    /// The wrapped value's bytes or an empty `Array`.
    public var bytes: [UInt8] {
        return self?.bytes ?? []
    }
}

extension Dictionary: KeyedCollection { }

/// Serializes dictionary data to CSV document data.
///
/// - Note: You should create a new `Serializer` dictionary you serialize.
public struct Serializer {
    private var serializedHeaders: Bool
    
    /// The struct configures serialization options
    var configuration: Config

    /// The callback that will be called with each row that is serialized.
    public var onRow: ([UInt8])throws -> ()

    /// Creates a new `Serializer` instance.
    ///
    /// - Parameter: The struct configures serialization options
    ///   - configuration: The struct that configures serialization options
    ///   - onRow: The callback that will be called with each row that is serialized.
    public init(configuration: Config = Config.default, onRow: @escaping ([UInt8])throws -> ()) {
        self.serializedHeaders = false
        self.configuration = configuration
        self.onRow = onRow
    }

    /// Serializes a dictionary to CSV document data. Usually this will be a dictionary of type
    /// `[BytesRepresentable: [BytesRepresentable]], but it can be any type you conform to the proper protocols.
    ///
    /// You can pass multiple dictionaries of the same structure into this method. The headers will only be serialized the
    /// first time it is called.
    ///
    /// - Note: When you pass a dictionary into this method, each value collection is expect to contain the same
    ///   number of elements, and will crash with `index out of bounds` if that assumption is broken.
    ///
    /// - Parameter data: The dictionary (or other object) to parse.
    /// - Returns: A `Result` instance with a `.failure` case with all the errors from the the `.onRow` callback calls.
    ///   If there are no errors, the result will be a `.success` case.
    @discardableResult
    public mutating func serialize<Data>(_ data: Data) -> Result<Void, ErrorList> where
        Data: KeyedCollection, Data.Key: BytesRepresentable, Data.Value: Collection, Data.Value.Element: BytesRepresentable,
        Data.Value.Index: Strideable, Data.Value.Index.Stride: SignedInteger
    {
        var errors = ErrorList()
        guard data.count > 0 else { return errors.result }

        if !self.serializedHeaders {
            let headers = data.keys.map { title -> [UInt8] in
                if let delimiter = self.configuration.cellDelimiter {
                    return title.bytes.escaping(delimiter)
                } else {
                    return title.bytes
                }
            }
            do { try self.onRow(Array(headers.joined(separator: [configuration.cellSeparator]))) }
            catch let error { errors.errors.append(error) }
            self.serializedHeaders = true
        }

        guard let first = data.first?.value else { return errors.result }
        (first.startIndex..<first.endIndex).forEach { index in
            let cells = data.values.map { column -> [UInt8] in
                if let delimiter = self.configuration.cellDelimiter {
                    return column[index].bytes.escaping(delimiter)
                } else {
                    return column[index].bytes
                }
            }
            do { try onRow(Array(cells.joined(separator: [configuration.cellSeparator]))) }
            catch let error { errors.errors.append(error) }
        }

        return errors.result
    }
}

/// A synchronous wrapper for the `Serializer` struct for parsing a whole CSV document.
public struct SyncSerializer {
    var configuration: Config

    /// Creates a new `SyncSerializer` instance.
    ///
    /// - Parameter configuration: The struct that configures serialization options
    
    public init (configuration: Config = Config.default) { self.configuration = configuration}

    /// Serializes a dictionary to CSV document data. Usually this will be a dictionary of type
    /// `[BytesRepresentable: [BytesRepresentable]], but it can be any type you conform to the proper protocols.
    ///
    /// - Note: When you pass a dictionary into this method, each value collection is expect to contain the same
    ///   number of elements, and will crash with `index out of bounds` if that assumption is broken.
    ///
    /// - Parameter data: The dictionary (or other object) to parse.
    /// - Returns: The serialized CSV data.
    public func serialize<Data>(_ data: Data) -> [UInt8] where
        Data: KeyedCollection, Data.Key: BytesRepresentable, Data.Value: Collection, Data.Value.Element: BytesRepresentable,
        Data.Value.Index: Strideable, Data.Value.Index.Stride: SignedInteger
    {
        var rows: [[UInt8]] = []
        rows.reserveCapacity(data.first?.value.count ?? 0)

        var serializer = Serializer(configuration: self.configuration) { row in rows.append(row) }
        serializer.serialize(data)

        return Array(rows.joined(separator: [10]))
    }
}
