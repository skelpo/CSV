import Foundation

final class _CSVSingleValueDecoder: SingleValueDecodingContainer {
    let codingPath: [CodingKey]
    let decoder: _CSVDecoder
    
    init(decoder: _CSVDecoder) {
        self.codingPath = decoder.codingPath
        self.decoder = decoder
    }
    
    func decodeNil() -> Bool {
        guard let cell = self.decoder.container.cell else { return true }
        return self.decoder.decodingOptions.nilCodingStrategy.isNull(cell)
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        guard let bool = self.decoder.decodingOptions.boolCodingStrategy.bool(from: cell) else {
            throw DecodingError.unableToExtract(type: type, at: self.codingPath)
        }

        return bool
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard let cell = self.decoder.container.cell else { throw DecodingError.nilValue(type: type, at: self.codingPath) }
        return String(cell)
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
