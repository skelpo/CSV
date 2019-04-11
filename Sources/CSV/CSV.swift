import Foundation

public struct CSV {
    public struct Column {
        public let header: String
        public var fields: [String?]
        
        public init(header: String, fields: [String?]) {
            self.header = header
            self.fields = fields
        }
    }
    
    internal struct Delimiter {
        static let comma = UInt8(ascii: ",")
        static let quote = UInt8(ascii: "\"")
        static let newLine = UInt8(ascii: "\n")
        static let carriageReturn = UInt8(ascii: "\r")
    }
}
