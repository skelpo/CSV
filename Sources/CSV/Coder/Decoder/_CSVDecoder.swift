import Foundation

public typealias CodingPath = [CodingKey]

final class _CSVDecoder: Decoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    
    let csv: [String: [String?]]?
    let row: [String: String?]?
    let cell: String?
    
    init(csv: [String: [String?]], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
        self.csv = csv
        self.row = nil
        self.cell = nil
    }

    init(row: [String: String?], path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
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
        fatalError()
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
    
    func decode<T>(_ type: T.Type, from data: Data)throws -> [T] where T: Decodable {
        let csv: [String: [String?]] = CSV.parse(data)
        let decoder = _CSVDecoder(csv: csv)
        return try Array<T>(from: decoder)
    }
}
