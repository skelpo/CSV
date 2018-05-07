@_exported import Bits
import Foundation

public struct CSV {
    public struct Column {
        let header: String
        var fields: [String?]
    }
}
