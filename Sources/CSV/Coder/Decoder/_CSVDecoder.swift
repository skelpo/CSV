import Foundation

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let stringDecoding: String.Encoding
    
    let csv: [String: [Data?]]?
    let row: [String: Data]?
    let cell: Data?
    
    init(csv: [String: [Data?]], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.userInfo = info
        self.stringDecoding = stringDecoding
        self.csv = csv
        self.row = nil
        self.cell = nil
    }

    init(row: [String: Data], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
        self.codingPath = path
        self.userInfo = info
        self.stringDecoding = stringDecoding
        self.csv = nil
        self.row = row
        self.cell = nil
    }
    
    init(cell: Data?, path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:], stringDecoding: String.Encoding) {
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
        let csv: [String: [Data?]] = try _CSVDecoder.organize(data, stringDecoding: stringDecoding)
        let decoder = _CSVDecoder(csv: csv, stringDecoding: stringDecoding)
        return try Array<T>(from: decoder)
    }
    
    static func organize(_ data: Data, stringDecoding: String.Encoding)throws -> [String: [Data?]] {
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
        
        var columns: [String: [Data?]] = [:]
        try (0...rowLength).forEach { (cellIndex) in
            var column = cells.map({ (row) -> Data? in
                return row[cellIndex].count > 0 ? row[cellIndex] : nil
            })
            guard let title = String(data: column.removeFirst()!, encoding: stringDecoding) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Found colunm title with \(stringDecoding) incompatible character"))
            }
            columns[title] = column
        }
        return columns
    }
}
