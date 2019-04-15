import Foundation

final class _CSVSingleValueDecoder: SingleValueDecodingContainer {
    let codingPath: [CodingKey]
    let decoder: _CSVDecoder
    
    init(decoder: _CSVDecoder) {
        self.codingPath = decoder.codingPath
        self.decoder = decoder
    }
    
    func decodeNil() -> Bool {
        return decoder.container.cell == nil || decoder.container.cell == [.N, .forwardSlash, .A] || decoder.container.cell == [.N, .A]
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        let value = try String(cell).lowercased()
        switch value {
        case "true", "yes", "t", "y", "1": return true
        case "false", "no", "f", "n", "0": return false
        default: throw DecodingError.unableToExtract(type: type, at: self.codingPath)
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        return try String(cell)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let double = cell.double else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return double
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let float = cell.float else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return float
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let int = cell.int else { throw DecodingError.unableToExtract(type: type, at: self.codingPath) }
        return int
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let column = codingPath.map { $0.stringValue }.joined(separator: ".")
        throw DecodingError.dataCorruptedError(in: self, debugDescription: "Found nested data in a cell in column '\(column)'")
    }
}
