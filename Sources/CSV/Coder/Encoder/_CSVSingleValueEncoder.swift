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
    
    func encodeNil() throws { self.container.data = [] }
    func encode(_ value: Bool) throws { self.container.data = boolEncoding.convert(value) }
    func encode(_ value: String) throws { self.container.data = value.bytes }
    func encode(_ value: Double) throws { self.container.data = value.bytes }
    func encode(_ value: Float) throws { self.container.data = value.bytes }
    func encode(_ value: Int) throws { self.container.data = value.bytes }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let column = self.codingPath.map { $0.stringValue }.joined(separator: ".")
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode nested data into cell in column '\(column)'"))
    }
}
