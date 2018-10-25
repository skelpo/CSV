@_exported import Bits
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
}
