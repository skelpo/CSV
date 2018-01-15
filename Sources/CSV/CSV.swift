@_exported import Bits

public struct CSV {
    public struct Column {
        let header: String
        var fields: [String?]
    }
    
    public static func parse(_ bytes: Bytes) -> [String: [String?]] {
        let parsed: [Column] = parse(bytes)
        var columns: [String: [String?]] = [:]
        
        for column in parsed {
            columns[column.header] = column.fields
        }
        
        return columns
    }
    
    public static func parse(_ bytes: Bytes) -> [String: Column] {
        let parsed: [Column] = parse(bytes)
        var columns: [String: Column] = [:]
        
        for column in parsed {
            columns[column.header] = column
        }
        
        return columns
        
    }
    
    public static func parse(_ bytes: Bytes) -> [Column] {
        return CSV.standardParse(bytes)
    }
}
