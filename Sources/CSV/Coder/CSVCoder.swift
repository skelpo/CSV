import Foundation

/// Encodes Swift types to CSV data.
///
/// This exampls shows how multiple instances of a `Person` type will be encoded
/// to CSV data. `Person` conforms to `Codable`, so it is compatible with both the
/// `CSVEndocder` and `CSVDecoder`.
///
/// ```
/// struct Person: Codable {
///    let firstName: String,
///    let lastName: String,
///    let age: Int
/// }
///
/// let people = [
///     Person(firstName: "Grace", lastName: "Hopper", age: 113),
///     Person(firstName: "Linus", lastName: "Torvold", age: 50)
/// ]
///
/// let data = try CSVEncoder().sync.encode(people)
/// print(String(decoding: data, as: UTF8.self))
///
/// /* Prints:
///  "firstName","lastName","age"
///  "Grace","Hopper","113"
///  "Linus","Torvold","50"
/// */
/// ```
public final class CSVEncoder {

    /// The encoding options the use when encoding an object.
    ///
    /// Currently, this decideds how `nil` and `bool` values should be handled.
    public var encodingOptions: CSVCodingOptions
    public var configuration: Config

    /// Creates a new `CSVEncoder` instance.
    ///
    /// - Parameter encodingOptions: The encoding options the use when encoding an object.
    public init(encodingOptions: CSVCodingOptions = .default, configuration: Config = Config()) {
        self.encodingOptions = encodingOptions
        self.configuration = configuration
    }

    /// Creates a `CSVSyncEncoder` using the registered encoding options.
    ///
    /// This encoder is for if you have several objects that you want to encode at
    /// a single time into a single document.
    public var sync: CSVSyncEncoder {
        return CSVSyncEncoder(encodingOptions: self.encodingOptions, configuration: self.configuration)
    }

    /// Creates a new `CSVAsyncEncoder` using the registered encoding options.
    ///
    /// This encoder is for if you have multiple objects that will be encoded separately,
    /// but into a single document.
    ///
    /// - Parameter onRow: The closure that will be called when each object passed
    ///   into the encoder is encoded to a row.
    /// - Returns: A `CSVAsyncEncoder` instance with the current encoder's encoding
    ///   options and the `onRow` closure as its callback.
    public func async(_ onRow: @escaping ([UInt8]) -> ()) -> CSVAsyncEncoder {
        return CSVAsyncEncoder(encodingOptions: self.encodingOptions, configuration: self.configuration, onRow: onRow)
    }
}

/// The encoder for encoding multiple objects at once into a single CSV document.
///
/// You can get an instance of the `CSVSyncEncoder` with the `CSVEncoder.sync` property.
public final class CSVSyncEncoder {
    internal var encodingOptions: CSVCodingOptions
    internal var configuration: Config

    internal init(encodingOptions: CSVCodingOptions, configuration: Config = Config()) {
        self.encodingOptions = encodingOptions
        self.configuration = configuration
    }

    /// Encodes an array of encodable objects into a single CSV document.
    ///
    /// - Parameter objects: The objects to encode to CSV rows.
    /// - Returns: The data for the CSV document.
    ///
    /// - Throws: Encoding errors that occur when encoding the given objects.
    public func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        var rows: [[UInt8]] = []
        rows.reserveCapacity(objects.count)

        let encoder = AsyncEncoder(encodingOptions: self.encodingOptions, configuration: self.configuration) { row in
            rows.append(row)
        }
        try objects.forEach(encoder.encode)

        return Data(rows.joined(separator: [10]))
    }
}

/// An encoder for encoding multiple objects separately into a single CSV document.
///
/// You can get an instance of the `CSVAsyncEncoder` using the `CSVEncoder.async(_:)` method.
public final class CSVAsyncEncoder {
    internal var encodingOptions: CSVCodingOptions
    private var encoder: AsyncEncoder

    internal init(encodingOptions: CSVCodingOptions, configuration: Config = Config(), onRow: @escaping ([UInt8]) -> ()) {
        self.encodingOptions = encodingOptions
        self.encoder = AsyncEncoder(encodingOptions: encodingOptions, configuration: configuration, onRow: onRow)
    }

    /// Encodes an `Encodable` object into a row for a CSV document and passes it into
    /// the `onRow` closure.
    ///
    /// - Parameter object: The object to encode to a CSV row.
    /// - Throws: Erros that occur when encoding the object passed in.
    public func encode<T>(_ object: T)throws where T: Encodable {
        try self.encoder.encode(object)
    }
}

/// Decodes CSV document data to Swift types.
///
/// This example shows how a simple `Person` type will be decoded from a CSV document.
/// Person` conforms to `Codable`, so it is compatible with both the `CSVEndocder` and `CSVDecoder`.
///
/// ```
/// struct Person: Codable {
///    let firstName: String,
///    let lastName: String,
///    let age: Int
/// }
///
/// let csv = """
/// "firstName","lastName","age"
/// "Grace","Hopper","113"
/// "Linus","Torvold","50"
/// """
/// let data = Data(csv.utf8)
///
/// let people = try CSVDecoder.sync.decode(Person.self, from: data)
/// print(people.map { $0.firstName }) // Prints: `["Grace","Linus"]`
/// ```
public final class CSVDecoder {

    /// The decoding options to use when decoding data to an object.
    ///
    /// This is currently used to specify how `nil` and `Bool` values should be handled.
    public var decodingOptions: CSVCodingOptions
    
    /// The CSV configuration to use when decoding or encoding
    ///
    /// This is used to specify if cells are wrapped in quotes and what the delimiter is (comma or tab, etc.)
    public var configuration: Config

    /// Creates a new `CSVDecoder` instance.
    ///
    /// - Parameter decodingOptions: The decoding options to use when decoding data to an object.
    public init(decodingOptions: CSVCodingOptions = .default, configuration: Config = Config()) {
        self.decodingOptions = decodingOptions
        self.configuration = configuration
    }

    /// Creates a `CSVSyncDecoder` with the registered encoding options.
    ///
    /// This decoder is for if you have whole CSV document you want to decode at once.
    public var sync: CSVSyncDecoder {
        return CSVSyncDecoder(decodingOptions: self.decodingOptions, configuration: self.configuration)
    }

    /// Creates a `CSVAsyncDecoder` instance with the registered encoding options.
    ///
    /// This decoder is for if you have separate chunks of the same CSV document that you will
    /// be decoding at different times.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type that the rows of the CSV document will be decoded to.
    ///   - length: The content length of the whole CSV document.
    ///   - onInstance: The closure that is called when an instance of `D` is decoded from the data passed in.
    ///
    /// - Returns: A `CSVAsyncDecoder` instance with the current encoder's encoding options and the
    ///   `.onInstance` closure as its callback.
    public func async<D>(for type: D.Type = D.self, length: Int, _ onInstance: @escaping (D) -> ()) -> CSVAsyncDecoder
        where D: Decodable
    {
        return CSVAsyncDecoder(
            decoding: D.self,
            onInstance: onInstance,
            length: length,
            decodingOptions: self.decodingOptions,
            configuration: self.configuration
        )
    }
}

/// A decoder for decoding a single CSV document all at once.
///
/// You can get an instance of `CSVSyncDecoder` from the `CSVDecoder.sync` property.
public final class CSVSyncDecoder {
    internal var decodingOptions: CSVCodingOptions
    internal var configuration: Config

    internal init(decodingOptions: CSVCodingOptions, configuration: Config = Config()) {
        self.decodingOptions = decodingOptions
        self.configuration = configuration
    }

    /// Decodes a whole CSV document into an array of a specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode the CSV rows to.
    ///   - data: The CSV data to decode.
    /// - Returns: An array of `D` instances, decoded from the data passed in.
    ///
    /// - Throws: Errors that occur during the decoding proccess.
    public func decode<D>(_ type: D.Type = D.self, from data: Data)throws -> [D] where D: Decodable {
        var result: [D] = []
        result.reserveCapacity(data.lazy.split(separator: "\n").count)

        let decoder = AsyncDecoder(decoding: type, path: [], decodingOptions: self.decodingOptions) { decoded in
            guard let typed = decoded as? D else {
                assertionFailure("Passed incompatible value into decoding completion callback")
                return
            }

            result.append(typed)
        }
        try decoder.decode(Array(data), length: data.count)

        return result
    }
}

/// A decoder for decoding sections of a CSV document at different times.
///
/// You can get an instance of `CSVAsyncDecoder` from the `CSVDecoder.async(for:length_:)` method.
public final class CSVAsyncDecoder {
    internal var length: Int
    internal var decoding: Decodable.Type
    internal var decodingOptions: CSVCodingOptions
    internal var configuration: Config
    private var rowDecoder: AsyncDecoder

    internal init<D>(decoding: D.Type, onInstance: @escaping (D) -> (), length: Int, decodingOptions: CSVCodingOptions, configuration: Config = Config())
        where D: Decodable
    {
        let callback = { (decoded: Decodable) in
            guard let typed = decoded as? D else {
                assertionFailure("Passed incompatible value into decoding completion callback")
                return
            }
            onInstance(typed)
        }

        self.length = length
        self.decoding = decoding
        self.decodingOptions = decodingOptions
        self.configuration = configuration
        self.rowDecoder = AsyncDecoder(
            decoding: D.self,
            path: [],
            decodingOptions: decodingOptions,
            configuration: configuration,
            onInstance: callback
        )

        rowDecoder.onInstance = callback
    }

    /// Decodes a section of a CSV document to instances of the registered `Decodable` type.
    ///
    /// When a whole row has been parsed from the data passed in, it is decoded and passed into
    /// the `.onInstance` callback that is registered.
    ///
    /// - Note: Each chunk of data passed in is assumed to come directly after the previous one
    ///   passed in. The chunks may not be passed in out of order.
    ///
    /// - Parameter data: A section of the CSV document to decode.
    /// - Throws: Errors that occur during the decoding process.
    public func decode<C>(_ data: C) throws where C: Collection, C.Element == UInt8 {
        try self.rowDecoder.decode(Array(data), length: self.length)
    }
}
