/// Wraps the Configuration options for Parse/Encode/Decode
public struct Config {
    public let cellSeparator: UInt8
    public let cellDelimiter: UInt8?
    
    public init(cellSeparator: UInt8 = 44, cellDelimiter: UInt8? = nil) {
        self.cellSeparator = cellSeparator
        self.cellDelimiter = cellDelimiter
    }
}
