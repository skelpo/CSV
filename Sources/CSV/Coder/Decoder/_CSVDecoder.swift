import Foundation
import Core

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let stringDecoding: String.Encoding
    
    let csv: [String: [Bytes?]]?
    let row: [String: Bytes]?
    let cell: Bytes?
    
    init(csv: [String: [Bytes?]], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.userInfo = info
        self.stringDecoding = stringDecoding
        self.csv = csv
        self.row = nil
        self.cell = nil
    }

    init(row: [String: Bytes], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.userInfo = info
        self.stringDecoding = stringDecoding
        self.csv = nil
        self.row = row
        self.cell = nil
    }
    
    init(cell: Bytes?, path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.userInfo = info
        self.stringDecoding = stringDecoding
        self.csv = nil
        self.row = nil
        self.cell = cell
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let row = self.row else {
            throw DecodingError.typeMismatch(
                [String: String?].self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get CSV row as expected format '[String: String?]'"
                )
            )
        }
        let container = _CSVKeyedDecoder<Key>(path: self.codingPath, row: row, stringDecoding: self.stringDecoding)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let csv = self.csv else {
            throw DecodingError.typeMismatch(
                [String: [String?]].self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get CSV data as expected format '[String: [String?]]'")
            )
        }
        return _CSVUnkeyedDecoder(columns: csv, path: self.codingPath, stringDecoding: self.stringDecoding)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard let cell = self.cell else {
            throw DecodingError.typeMismatch(
                String?.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get CSV cell as expected format 'String?'")
            )
        }
        return _CSVSingleValueDecoder(value: cell, path: self.codingPath, stringDecoding: self.stringDecoding)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data, stringDecoding: String.Encoding)throws -> [T] where T: Decodable {
        let csv: [String: [Bytes?]] = try _CSVDecoder.organize(data, stringDecoding: stringDecoding)
        let decoder = _CSVDecoder(csv: csv, stringDecoding: stringDecoding)
        return try Array<T>(from: decoder)
    }
    
    static func organize(_ data: Data, stringDecoding: String.Encoding)throws -> [String: [Bytes?]] {
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
                guard let title = String(data: Data(currentCell), encoding: stringDecoding) else {
                    throw CoreError(
                        identifier: "dataToString",
                        reason: "Converting byte array to string failed",
                        possibleCauses: ["This could be due to an incorrect string encoding type"]
                    )
                }
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
                columns[columnIndex].cells.append(currentCell.count > 0 ? nil : currentCell)
                
                columnIndex += 1
                currentCell = []
            case .newLine:
                if inQuotes { currentCell.append(.newLine); break }
                columns[columnIndex].cells.append(currentCell.count > 0 ? nil : currentCell)
            
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
