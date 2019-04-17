import Foundation

final class _CSVSingleValueEncoder: SingleValueEncodingContainer {
    let codingPath: [CodingKey]
    let container: DataContainer
    let encodingOptions: CSVCodingOptions
    
    init(container: DataContainer, path: CodingPath, encodingOptions: CSVCodingOptions) {
        self.codingPath = path
        self.container = container
        self.encodingOptions = encodingOptions
    }
    
    func encodeNil() throws {
        self.container.data = self.encodingOptions.nilCodingStrategy.bytes()
    }
    func encode(_ value: Bool) throws {
        self.container.data = self.encodingOptions.boolCodingStrategy.bytes(from: value)
    }
    func encode(_ value: String) throws { self.container.data = value.bytes }
    func encode(_ value: Double) throws { self.container.data = value.bytes }
    func encode(_ value: Float) throws { self.container.data = value.bytes }
    func encode(_ value: Int) throws { self.container.data = value.bytes }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let column = self.codingPath.map { $0.stringValue }.joined(separator: ".")
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode nested data into cell in column '\(column)'"))
    }
}
