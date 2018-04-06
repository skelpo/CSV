@_exported import Bits
import Foundation

public struct CSV {
    public struct Column {
        let header: String
        var fields: [String?]
    }
    
    public static func parse(_ data: Data) -> [String: [String?]] {
        return parse(data).reduce(into: [:]) { (columns, column) in
            columns[column.header] = column.fields
        }
    }
    
    public static func parse(_ data: Data) -> [String: Column] {
        return parse(data).reduce(into: [:]) { (columns, column) in
            columns[column.header] = column
        }
    }
    
    public static func parse(_ data: Data) -> [Column] {
        return CSV.standardParse(data)
    }
}
