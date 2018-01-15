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
        var index: Int = 0
        var columnIndex: Int = 0
        var columns: [Column] = []
        let count: Int = bytes.count
        
        var stack: Bytes = []
        
        while true {
            let character = bytes[index]
            if character == .comma  {
                columns.append(Column(header: stack.makeString(), fields: []))
                stack = []
            } else if character == .newLine {
                columns.append(Column(header: stack.makeString(), fields: []))
                stack = []
                index += 1
                break
            } else {
                stack.append(character)
            }
            
            index += 1
        }
        
        while index < count {
            let character = bytes[index]
            if character == .comma || character == .newLine {
                if stack == [] {
                    columns[columnIndex].fields.append(nil)
                } else {
                    columns[columnIndex].fields.append(stack.makeString())
                }
                
                columnIndex = character == .comma ? columnIndex + 1 : 0
                stack = []
            } else {
                stack.append(character)
            }
            
            index += 1
        }
        
        return columns
    }
}
