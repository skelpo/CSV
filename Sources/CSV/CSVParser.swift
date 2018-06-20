import Foundation

extension CSV {
    public static func parse(_ csv: Data) -> [String: [String?]] {
        let data = Array(csv)
        let end = data.endIndex
        let estimatedRowCount = data.reduce(0) { $1 == .newLine ? $0 + 1 : $0 }
        
        var columns: [(title: String, cells: [String?])] = []
        var columnIndex = 0
        var iterator = data.startIndex
        var inQuotes = false
        var cellStart = data.startIndex
        var cellEnd = data.startIndex
        
        header: while iterator < end {
            let byte = data[iterator]
            switch byte {
            case .quote:
                inQuotes.toggle()
                cellEnd += 1
            case .comma:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case .newLine, .carriageReturn:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                let increment = byte == .newLine ? 1 : 2
                cellStart = iterator + increment
                cellEnd = iterator + increment
                iterator += increment
                break header
            default: cellEnd += 1
            }
            iterator += 1
        }
        
        while iterator < end {
            let byte = data[iterator]
            switch byte {
            case .quote:
                inQuotes.toggle()
                cellEnd += 1
            case .comma:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex += 1
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case .newLine, .carriageReturn:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex = 0
                let increment = byte == .newLine ? 1 : 2
                cellStart = iterator + increment
                cellEnd = iterator + increment
                iterator += increment
                continue
            default: cellEnd += 1
            }
            iterator += 1
        }
        
        if cellEnd > cellStart {
            var cell = Array(data[cellStart...cellEnd-1])
            cell.removeAll { $0 == .quote }
            columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
        }
        
        return columns.reduce(into: [:]) { result, column in
            result[column.title] = column.cells
        }
    }
    
    public static func parse(_ data: Data) -> [String: Column] {
        let elements: [String: [String?]] = self.parse(data)
        
        return elements.reduce(into: [:]) { columns, element in
            columns[element.key] = Column(header: element.key, fields: element.value)
        }
    }
    
    public static func parse(_ data: Data) -> [Column] {
        let elements: [String: [String?]] = self.parse(data)
        
        return elements.reduce(into: []) { columns, element in
            columns.append(Column(header: element.key, fields: element.value))
        }
    }
}
