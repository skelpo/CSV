import Foundation

final class _CSVKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    let codingPath: [CodingKey]
    let allKeys: [K]
    let row: [String: Bytes]
    
    init(path: CodingPath, row: [String: Bytes]) {
        self.codingPath = path
        self.allKeys = Array(row.keys).compactMap(K.init)
        self.row = row
    }
    
    func contains(_ key: K) -> Bool {
        return row[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: K) throws -> Bool {
        let cell = row[key.stringValue]
        return cell == nil || cell == [.N, .forwardSlash, .A] || cell == [.N, .A]
    }
    
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let cell = try row.value(for: key)
        let value = try String(cell).lowercased()
        switch value {
        case "true", "yes", "t", "y", "1": return true
        case "false", "no", "f", "n", "0": return false
        default: throw DecodingError.unableToExtract(type: type, at: self.codingPath + [key])
        }
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        let cell = try row.value(for: key)
        return try String(cell)
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        let value = try row.value(for: key)
        guard let double = value.double else { throw DecodingError.unableToExtract(type: type, at: self.codingPath + [key]) }
        return double
    }
    
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        let value = try row.value(for: key)
        guard let float = value.float else { throw DecodingError.unableToExtract(type: type, at: self.codingPath + [key]) }
        return float
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        let value = try row.value(for: key)
        guard let int = value.int else { throw DecodingError.unableToExtract(type: type, at: self.codingPath + [key]) }
        return int
    }
    
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        let cell = try row.value(for: key)
        let decoder = _CSVDecoder(cell: cell, path: self.codingPath + [key])
        return try T(from: decoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let column = codingPath.map { $0.stringValue }.joined(separator: ".")
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Found nested data in a cell in column '\(column)'")
    }
    
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        let column = codingPath.map { $0.stringValue }.joined(separator: ".")
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Found nested data in a cell in column '\(column)'")
    }
    
    func superDecoder() throws -> Decoder {
        let key = K(stringValue: "super")!
        throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.codingPath + [key], debugDescription: "Cannot create super decoder for CSV structure"))
    }
    
    func superDecoder(forKey key: K) throws -> Decoder {
        throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.codingPath + [key], debugDescription: "Cannot create super decoder for CSV structure"))
    }
}
