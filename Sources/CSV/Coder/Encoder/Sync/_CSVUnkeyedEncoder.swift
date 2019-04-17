import Foundation

final class _CSVUnkeyedEncoder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    let container: DataContainer
    let encodingOptions: CSVCodingOptions
    
    init(container: DataContainer, path: CodingPath, encodingOptions: CSVCodingOptions) {
        self.container = container
        self.codingPath = path
        self.encodingOptions = encodingOptions
    }
    
    var count: Int {
        return container.data.split(separator: "\n").count
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
        let encoder = _CSVEncoder(
            container: DataContainer(titles: self.container.data.count > 0),
            path: self.codingPath,
            encodingOptions: self.encodingOptions
        )
        try value.encode(to: encoder)
        self.container.data.append(contentsOf: encoder.container.data.dropLast() + ["\n"])
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CSVKeyedEncoder<NestedKey>(
            container: self.container,
            path: self.codingPath,
            encodingOptions: self.encodingOptions
        )
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
}
