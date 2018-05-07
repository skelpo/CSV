import Foundation

extension CSV {
    public static func parse(_ data: Data) -> [String: [String?]] {
        let rows = data.split(separator: .newLine, omittingEmptySubsequences: false)
        var cells = rows.map({ $0.split(separator: .comma, omittingEmptySubsequences: false) })
        let rowLength = cells[0].count - 1
        
        for count in 1...cells.count - 1 {
            if cells[cells.count - count].count < rowLength {
                _ = cells.removeLast()
            } else {
                break
            }
        }
        
        var columns: [String: [String?]] = [:]
        (0...rowLength).forEach { (cellIndex) in
            var column = cells.map({ (row) -> String? in
                return String(data: row[cellIndex], encoding: .utf8)
            })
            let title = column.removeFirst()!
            columns[title] = column
        }
        return columns
    }
    
    public static func parse(_ data: Data) -> [String: Column] {
        let rows = data.split(separator: .newLine, omittingEmptySubsequences: false)
        var cells = rows.map({ $0.split(separator: .comma, omittingEmptySubsequences: false) })
        let rowLength = cells[0].count - 1
        
        for count in 1...cells.count - 1 {
            if cells[cells.count - count].count < rowLength {
                _ = cells.removeLast()
            } else {
                break
            }
        }
        
        var columns: [String: Column] = [:]
        (0...rowLength).forEach { (cellIndex) in
            var column = cells.map({ (row) -> String? in
                return String(data: row[cellIndex], encoding: .utf8)
            })
            let title = column.removeFirst()!
            columns[title] = CSV.Column(header: title, fields: column)
        }
        return columns
    }
    
    public static func parse(_ data: Data) -> [Column] {
        let rows = data.split(separator: .newLine, omittingEmptySubsequences: false)
        var cells = rows.map({ $0.split(separator: .comma, omittingEmptySubsequences: false) })
        let rowLength = cells[0].count - 1
        
        for count in 1...cells.count - 1 {
            if cells[cells.count - count].count < rowLength {
                _ = cells.removeLast()
            } else {
                break
            }
        }
        
        return (0...rowLength).map { (cellIndex) -> CSV.Column in
            var column = cells.map({ (row) -> String? in
                return String(data: row[cellIndex], encoding: .utf8)
            })
            return CSV.Column(header: column.removeFirst()!, fields: column)
        }
    }
}
