import Foundation

final class AsyncSingleValueEncoder: SingleValueEncodingContainer {
    let codingPath: [CodingKey]
    let encoder: AsyncEncoder
    
    init(path: [CodingKey], encoder: AsyncEncoder) {
        self.codingPath = path
        self.encoder = encoder
    }

    var delimiter: UInt8? {
        return self.encoder.configuration.cellDelimiter
    }

    func encodeNil() throws {
        let value = self.encoder.encodingOptions.nilCodingStrategy.bytes().escaping(self.delimiter)
        self.encoder.container.cells.append(value)
    }
    func encode(_ value: Bool) throws {
        let value = self.encoder.encodingOptions.boolCodingStrategy.bytes(from: value).escaping(self.delimiter)
        self.encoder.container.cells.append(value)
    }
    func encode(_ value: String) throws { self.encoder.container.cells.append(value.bytes.escaping(self.delimiter)) }
    func encode(_ value: Double) throws { self.encoder.container.cells.append(value.bytes.escaping(self.delimiter)) }
    func encode(_ value: Float)  throws { self.encoder.container.cells.append(value.bytes.escaping(self.delimiter)) }
    func encode(_ value: Int)    throws { self.encoder.container.cells.append(value.bytes.escaping(self.delimiter)) }

    func encode<T>(_ value: T) throws where T : Encodable {
        let column = self.codingPath.map { $0.stringValue }.joined(separator: ".")
        throw EncodingError.invalidValue(value, EncodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Cannot encode nested data into cell in column '\(column)'"
        ))
    }
}
