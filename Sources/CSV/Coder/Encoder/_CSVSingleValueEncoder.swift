import Foundation

final class _CSVSingleValueEncoder: SingleValueEncodingContainer {
    let codingPath: [CodingKey]
    let container: DataContainer
    let boolEncoding: BoolEncodingStrategy
    let stringEncoding: String.Encoding
    
    init(container: DataContainer, path: CodingPath, boolEncoding: BoolEncodingStrategy, stringEncoding: String.Encoding) {
        self.codingPath = path
        self.container = container
        self.boolEncoding = boolEncoding
        self.stringEncoding = stringEncoding
    }
    
    func encodeNil() throws {}
    
    func encode(_ value: Bool) throws {
        self.container.data = boolEncoding.convert(value)
    }
    
    func encode(_ value: String) throws {
        guard let data = value.data(using: self.stringEncoding) else {
            throw EncodingError.unableToConvert(value: value, at: self.codingPath, encoding: self.stringEncoding)
        }
        self.container.data = data
    }
    
    func encode(_ value: Double) throws {
        let double = String(value)
        guard let data = double.data(using: self.stringEncoding) else {
            throw EncodingError.unableToConvert(value: double, at: self.codingPath, encoding: self.stringEncoding)
        }
        self.container.data = data
    }
    
    func encode(_ value: Float) throws {
        let float = String(value)
        guard let data = float.data(using: self.stringEncoding) else {
            throw EncodingError.unableToConvert(value: float, at: self.codingPath, encoding: self.stringEncoding)
        }
        self.container.data = data
    }
    
    func encode(_ value: Int) throws {
        let int = String(value)
        guard let data = int.data(using: self.stringEncoding) else {
            throw EncodingError.unableToConvert(value: int, at: self.codingPath, encoding: self.stringEncoding)
        }
        self.container.data = data
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let column = self.codingPath.map { $0.stringValue }.joined(separator: ".")
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode nested data into cell in column '\(column)'"))
    }
}
