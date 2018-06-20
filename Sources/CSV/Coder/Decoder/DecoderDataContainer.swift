import Foundation
import Bits

final class DecoderDataContainer {
    var allKeys: [CodingKey]?
    let data: [UInt8]
    
    private(set) var row: [String: Bytes]!
    private(set) var cell: Bytes?
    private(set) var header: [String]
    
    private var dataIndex: Int
    
    init(data: [UInt8])throws {
        self.allKeys = nil
        self.row = [:]
        self.cell = nil
        
        self.data = data
        self.header = []
        self.dataIndex = data.startIndex
        
        try self.configure()
    }
    
    private func configure()throws {
        self.header.reserveCapacity(self.data.lazy.split(separator: .newLine).first?.reduce(0) { $1 == .comma ? $0 + 1 : $0 } ?? 0)
        
        var cellStart = self.dataIndex
        var cellEnd = self.dataIndex
        var inQuote: Bool = false
        header: while self.dataIndex < data.endIndex {
            let byte = data[self.dataIndex]
            switch byte {
            case .quote:
                inQuote.toggle()
                cellEnd += 1
            case .comma:
                if inQuote { fallthrough }
                var cell = Array(self.data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                try self.header.append(String(cell))
                
                cellStart = self.dataIndex + 1
                cellEnd = self.dataIndex + 1
            case .newLine, .carriageReturn:
                if inQuote { fallthrough }
                var cell = Array(self.data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                try self.header.append(String(cell))
                
                self.dataIndex = byte == .newLine ? self.dataIndex + 1 : self.dataIndex + 2
                break header
            default: cellEnd += 1
            }
            self.dataIndex += 1
        }
        
        self.row.reserveCapacity(self.header.count)
    }
    
    func cell(for key: CodingKey) {
        self.cell = row[key.stringValue]
    }
    
    func incremetRow() {
        guard self.dataIndex < data.endIndex else {
            self.row = nil
            return
        }
        
        var cellStart = self.dataIndex
        var cellEnd = self.dataIndex
        var inQuote: Bool = false
        var columnIndex: Int = 0
        
        while self.dataIndex < data.endIndex {
            let byte = data[self.dataIndex]
            switch byte {
            case .quote:
                inQuote.toggle()
                cellEnd += 1
            case .comma:
                if inQuote { fallthrough }
                var cell = Array(self.data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                self.row[header[columnIndex]] = cell
                
                cellStart = self.dataIndex + 1
                cellEnd = self.dataIndex + 1
                columnIndex += 1
            case .newLine, .carriageReturn:
                if inQuote { fallthrough }
                var cell = Array(self.data[cellStart...cellEnd-1])
                cell.removeAll { $0 == .quote }
                self.row[header[columnIndex]] = cell
                
                self.dataIndex = byte == .newLine ? self.dataIndex + 1 : self.dataIndex + 2
                return
            default: cellEnd += 1
            }
            self.dataIndex += 1
        }
    }
}
