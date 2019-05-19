/// Wraps the Configuration options for Parse/Encode/Decode


/// The `Config` struct allows for configuring `Parser` and `Serializer`
/// to allow for separators other than comma or string delimiters
/// like quotation marks
public struct Config {
    public let cellSeparator: UInt8
    public let cellDelimiter: UInt8?
    
    public static let `default`: Config = Config(cellSeparator: 44, cellDelimiter: 34)
    
    /// Creates a new `Config` instance
    ///
    /// - Parameters:
    ///   - cellSeparator: the cell separator (44 for "," by default)
    ///   - cellDelimiter: the string delimiter (nil by default, 34 would be for question marks)
    public init(cellSeparator: UInt8, cellDelimiter: UInt8?) {
        self.cellSeparator = cellSeparator
        self.cellDelimiter = cellDelimiter
    }
}
