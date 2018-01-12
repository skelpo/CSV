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
        var rows = bytes.split(separator: Byte.newLine)
        guard let headers = rows.first?.split(separator: Byte.comma) else {
            return []
        }
        rows.removeFirst()
        
        var columns: [Column]  = headers.map({ header in
            let head = header.makeString()
            let column = Column(header: head, fields: [])
            return column
        })
        
        for row in rows {
            for (cell, columnIndex) in zip(row.split(separator: Byte.comma, omittingEmptySubsequences: false), 0...columns.count-1) {
                let text = cell == [] ? nil : cell.makeString()
                columns[columnIndex].fields.append(text)
            }
        }
        
        return columns
    }
}
