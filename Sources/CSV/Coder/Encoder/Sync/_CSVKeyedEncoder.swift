import Foundation

final class _CSVKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    let codingPath: [CodingKey]
    let container: DataContainer
    let encodingOptions: CSVCodingOptions
    
    init(container: DataContainer, path: CodingPath, encodingOptions: CSVCodingOptions) {
        self.container = container
        self.codingPath = path
        self.encodingOptions = encodingOptions
    }
    
    func titleEncode(for key: K, converter: ()throws -> [UInt8])rethrows {
        if self.container.titlesCreated {
            try self.container.data.append(contentsOf: converter() + ",")
        } else {
            let lines = self.container.data.split(separator: "\n")
            let headers = lines.first == nil ? [] : lines.first! + ","
            let body = lines.last == nil ? [] : lines.last! + ","
            try self.container.data = (headers + key.stringValue.bytes) + "\n" + (body + converter())
        }
    }
    
    func encodeNil(forKey key: K) throws {
        let value = self.encodingOptions.nilCodingStrategy.bytes()
        self.titleEncode(for: key) { value }
    }
    func encode(_ value: Bool, forKey key: K) throws {
        let value = self.encodingOptions.boolCodingStrategy.bytes(from: value)
        self.titleEncode(for: key) { value }
    }
    func encode(_ value: Double, forKey key: K) throws { self.titleEncode(for: key) { value.bytes } }
    func encode(_ value: Float, forKey key: K) throws { self.titleEncode(for: key) { value.bytes } }
    func encode(_ value: Int, forKey key: K) throws { self.titleEncode(for: key) { value.bytes } }
    func encode(_ value: String, forKey key: K) throws { self.titleEncode(for: key) { value.bytes } }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        try self.titleEncode(for: key) {
            let encoder = _CSVEncoder(
                container: DataContainer(titles: true),
                path: self.codingPath,
                encodingOptions: self.encodingOptions
            )
            try value.encode(to: encoder)
            return encoder.container.data
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CSVKeyedEncoder<NestedKey>(
            container: self.container,
            path: self.codingPath + [key],
            encodingOptions: self.encodingOptions
        )
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
    
    func superEncoder() -> Encoder {
        return _CSVEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return _CSVEncoder(container: self.container, path: self.codingPath + [key], encodingOptions: self.encodingOptions)
    }
}
