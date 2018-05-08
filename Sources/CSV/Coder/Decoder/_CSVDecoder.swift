import Foundation

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    
    let csv: [String: [String?]]?
    let row: [String: String]?
    let cell: String?
    
    init(csv: [String: [String?]], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
        self.csv = csv
        self.row = nil
        self.cell = nil
    }

    init(row: [String: String], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
        self.csv = nil
        self.row = row
        self.cell = nil
    }
    
    init(cell: String?, path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
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
        let container = _CSVKeyedDecoder<Key>(path: self.codingPath, row: row)
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
        return _CSVUnkeyedDecoder(columns: csv, path: self.codingPath)
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
        return _CSVSingleValueDecoder(value: cell, path: self.codingPath)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data)throws -> [T] where T: Decodable {
        let csv: [String: [String?]] = CSV.parse(data)
        let decoder = _CSVDecoder(csv: csv)
        return try Array<T>(from: decoder)
    }
}
