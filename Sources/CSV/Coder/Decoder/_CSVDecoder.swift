import Foundation

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let userInfo: [CodingUserInfoKey : Any]
    var codingPath: [CodingKey]
    
    let container: DecoderDataContainer
    
    init(csv: [String: [Bytes?]], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
        self.container = DecoderDataContainer(columns: csv)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard self.container.row != nil else {
            throw DecodingError.typeMismatch(
                [String: String?].self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get CSV row as expected format '[String: String?]'"
                )
            )
        }
        let container = _CSVKeyedDecoder<Key>(decoder: self)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return _CSVUnkeyedDecoder(decoder: self, path: self.codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _CSVSingleValueDecoder(decoder: self)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data)throws -> [T] where T: Decodable {
        let csv: [String: [Bytes?]] = try _CSVDecoder.organize(data)
        let decoder = _CSVDecoder(csv: csv)
        return try Array<T>(from: decoder)
    }
    
    static func organize(_ data: Data)throws -> [String: [Bytes?]] {
        let end = data.endIndex
        
        var columns: [(title: String, cells: [Bytes?])] = []
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
                try columns.append((String(currentCell), []))
                
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
                columns[columnIndex].cells.append(currentCell.count > 0 ? currentCell : nil)
                
                columnIndex += 1
                currentCell = []
            case .newLine:
                if inQuotes { currentCell.append(.newLine); break }
                columns[columnIndex].cells.append(currentCell.count > 0 ? currentCell: nil)
            
                columnIndex = 0
                currentCell = []
            default: currentCell.append(byte)
            }
            iterator += 1
        }
        
        var dictionaryResult: [String: [Bytes?]] = [:]
        var resultIterator = columns.startIndex
        
        while resultIterator < columns.endIndex {
            let column = columns[resultIterator]
            dictionaryResult[column.title] = column.cells
            
            resultIterator += 1
        }
        
        return dictionaryResult
    }
}
