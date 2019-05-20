// Wraps the Configuration options for Parse/Encode/Decode


/// The `Config` struct allows for configuring `Parser` and `Serializer`
/// to allow for separators other than comma or string delimiters
/// like quotation marks
public struct Config {

    /// The character that separates one cell from another.
    public let cellSeparator: UInt8

    /// The character that is used to denote the start and end of a cell's contents.
    public let cellDelimiter: UInt8?

    /// The deault `Config` instance that uses commas for cell separators and double quotes
    /// for cell delimiters.
    public static let `default`: Config = Config(cellSeparator: 44, cellDelimiter: 34)
    
    /// Creates a new `Config` instance
    ///
    /// - Parameters:
    ///   - cellSeparator: The character that separates one cell from another.
    ///   - cellDelimiter: The character that is used to denote the start and end of a cell's contents.
    public init(cellSeparator: UInt8, cellDelimiter: UInt8?) {
        self.cellSeparator = cellSeparator
        self.cellDelimiter = cellDelimiter
    }

    /// Creates a new `Config` instance from `UnicdeScalar` literals.
    ///
    /// - Parameters:
    ///   - separator: The `UnicodeScalar` for the separator between cells (`','`).
    ///   - delimiter: The `UnicdeScalar` for the delimiter that marks the start and end of a cell (`'"'`).
    public init(separator: UnicodeScalar, delimiter: UnicodeScalar) {
        self.cellSeparator = UInt8(ascii: separator)
        self.cellDelimiter = UInt8(ascii: delimiter)
    }
}
