import Foundation

extension CSV {
    public static func parse(_ data: Data, stringEncoding: String.Encoding = .utf8) -> [String: [String?]] {
        let end = data.endIndex
        
        var columns: [(title: String, cells: [String?])] = []
        var columnIndex = 0
        var iterator = data.startIndex
        var inQuotes = false
        var currentCell: Bytes = []
        
        header: while iterator < end {
            let byte = data[iterator]
            switch byte {
            case .quote: inQuotes = !inQuotes
            case .comma, .newLine:
                if inQuotes { currentCell.append(byte); break }
                guard let title = String(data: Data(currentCell), encoding: stringEncoding) else { return [:] }
                columns.append((title, []))
                
                currentCell = []
                if byte == .newLine { iterator += 1; break header }
            default: currentCell.append(byte)
            }
            iterator += 1
        }
        
        while iterator < end {
            let byte = data[iterator]
            switch byte {
            case .quote: inQuotes = !inQuotes
            case .comma:
                if inQuotes { currentCell.append(.comma); break }
                columns[columnIndex].cells.append(currentCell.count > 0 ? nil : String(data: Data(currentCell), encoding: stringEncoding))
                
                columnIndex += 1
                currentCell = []
            case .newLine:
                if inQuotes { currentCell.append(.newLine); break }
                columns[columnIndex].cells.append(currentCell.count > 0 ? nil : String(data: Data(currentCell), encoding: stringEncoding))
                
                columnIndex = 0
                currentCell = []
            default: currentCell.append(byte)
            }
            iterator += 1
        }
        
        var dictionaryResult: [String: [String?]] = [:]
        var resultIterator = columns.startIndex
        
        while resultIterator < columns.endIndex {
            let column = columns[resultIterator]
            dictionaryResult[column.title] = column.cells
            
            resultIterator += 1
        }
        
        return dictionaryResult
        
    }
    
    public static func parse(_ data: Data, stringEncoding: String.Encoding = .utf8) -> [String: Column] {
        let elements: [String: [String?]] = self.parse(data, stringEncoding: stringEncoding)
        
        return elements.reduce(into: [:]) { columns, element in
            columns[element.key] = Column(header: element.key, fields: element.value)
        }
    }
    
    public static func parse(_ data: Data, stringEncoding: String.Encoding = .utf8) -> [Column] {
        let elements: [String: [String?]] = self.parse(data, stringEncoding: stringEncoding)
        
        return elements.reduce(into: []) { columns, element in
            columns.append(Column(header: element.key, fields: element.value))
        }
    }
}
