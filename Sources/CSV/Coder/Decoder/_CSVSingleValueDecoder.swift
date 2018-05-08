import Foundation

final class _CSVSingleValueDecoder: SingleValueDecodingContainer {
    let codingPath: [CodingKey]
    let stringDecoding: String.Encoding
    let value: Data?
    
    init(value: Data?, path: CodingPath, stringDecoding: String.Encoding) {
        self.codingPath = path
        self.stringDecoding = stringDecoding
        self.value = value
    }
    
    func decodeNil() -> Bool { return self.value == nil }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let cell = self.value else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let value = String(data: cell, encoding: self.stringDecoding) else {
            throw DecodingError.dataToStringFailed(path: self.codingPath, encoding: self.stringDecoding)
        }
        switch value.lowercased() {
        case "true", "yes", "t", "y", "1": return true
        case "false", "no", "f", "n", "0": return false
        default: throw DecodingError.unableToExtract(type: type, at: self.codingPath)
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard let cell = self.value else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let value = String(data: cell, encoding: self.stringDecoding) else {
            throw DecodingError.dataToStringFailed(path: self.codingPath, encoding: self.stringDecoding)
        }
        return value
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        guard let cell = self.value else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let double = cell.double else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return double
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        guard let cell = self.value else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let float = cell.float else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return float
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard let cell = self.value else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let int = cell.int else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return int
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let column = codingPath.map { $0.stringValue }.joined(separator: ".")
        throw DecodingError.dataCorruptedError(in: self, debugDescription: "Found nested data in a cell in column '\(column)'")
    }
}
