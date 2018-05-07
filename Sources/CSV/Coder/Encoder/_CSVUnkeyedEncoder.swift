import Foundation

final class _CSVUnkeyedEncoder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    let container: DataContainer
    let boolEncoding: BoolEncodingStrategy
    let stringEncoding: String.Encoding
    
    init(container: DataContainer, path: CodingPath, boolEncoding: BoolEncodingStrategy, stringEncoding: String.Encoding) {
        self.container = container
        self.codingPath = path
        self.boolEncoding = boolEncoding
        self.stringEncoding = stringEncoding
    }
    
    var count: Int {
        return container.data.split(separator: .newLine).count
    }
    
    func fail(with value: Any) -> Error {
        return EncodingError.invalidValue(value, EncodingError.Context.init(codingPath: self.codingPath, debugDescription: "Cannot encode single values to array in CSV"))
    }
    
    func encodeNil() throws { throw self.fail(with: Optional<Any>.none as Any) }
    func encode(_ value: Bool) throws { throw self.fail(with: value) }
    func encode(_ value: String) throws { throw self.fail(with: value) }
    func encode(_ value: Double) throws { throw self.fail(with: value) }
    func encode(_ value: Float) throws { throw self.fail(with: value) }
    func encode(_ value: Int) throws { throw self.fail(with: value) }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = _CSVEncoder(data: DataContainer(), path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        try value.encode(to: encoder)
        self.container.data.append(contentsOf: encoder.data.data.dropLast() + [.newLine])
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CSVKeyedEncoder<NestedKey>(container: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(data: self.container, path: self.codingPath, boolEncoding: self.boolEncoding, stringEncoding: self.stringEncoding)
    }
}
