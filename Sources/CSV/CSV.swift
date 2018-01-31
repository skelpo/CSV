@_exported import Bits
import Foundation

public struct CSV {
    public struct Column {
        let header: String
        var fields: [String?]
    }
    
    public static func parse(_ data: Data) -> [String: [String?]] {
        let parsed: [Column] = parse(data)
        var columns: [String: [String?]] = [:]
        
        for column in parsed {
            columns[column.header] = column.fields
        }
        
        return columns
    }
    
    public static func parse(_ data: Data) -> [String: Column] {
        let parsed: [Column] = parse(data)
        var columns: [String: Column] = [:]
        
        for column in parsed {
            columns[column.header] = column
        }
        
        return columns
        
    }
    
    public static func parse(_ data: Data) -> [Column] {
        return CSV.standardParse(data)
    }
}
