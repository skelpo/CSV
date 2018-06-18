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
        
        var currentCell: [UInt8] = []
        var inQuote: Bool = false
        header: while self.dataIndex < data.endIndex {
            let byte = data[self.dataIndex]
            switch byte {
            case .quote: inQuote.toggle()
            case .comma:
                if inQuote { fallthrough }
                try self.header.append(String(currentCell))
                
                currentCell = []
            case .newLine, .carriageReturn:
                if inQuote { fallthrough }
                try self.header.append(String(currentCell))
                
                currentCell = []
                self.dataIndex = byte == .newLine ? self.dataIndex + 1 : self.dataIndex + 2
                break header
            default: currentCell.append(byte)
            }
            self.dataIndex += 1
        }
    }
    
    func cell(for key: CodingKey) {
        self.cell = row[key.stringValue]
    }
    
    func incremetRow() {
        guard self.dataIndex < data.endIndex else {
            self.row = nil
            return
        }
        
        var currentCell: [UInt8] = []
        var inQuote: Bool = false
        var columnIndex: Int = 0
        
        while self.dataIndex < data.endIndex {
            let byte = data[self.dataIndex]
            switch byte {
            case .quote: inQuote.toggle()
            case .comma:
                if inQuote { fallthrough }
                self.row[header[columnIndex]] = currentCell
                
                currentCell = []
                columnIndex += 1
            case .newLine, .carriageReturn:
                if inQuote { fallthrough }
                self.row[header[columnIndex]] = currentCell
                
                self.dataIndex = byte == .newLine ? self.dataIndex + 1 : self.dataIndex + 2
                return
            default: currentCell.append(byte)
            }
            self.dataIndex += 1
        }
    }
}
