import Foundation

final class AsyncUnkeyedEncoder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var encoder: AsyncEncoder

    init(encoder: AsyncEncoder) {
        self.encoder = encoder
        self.codingPath = []
    }
    
    var count: Int {
        return 0
    }
    
    func fail(with value: Any) -> Error {
        return EncodingError.invalidValue(value, EncodingError.Context(
            codingPath: [],
            debugDescription: "Cannot use CSV decoder to decode array values"
        ))
    }
    
    func encodeNil() throws { throw self.fail(with: Optional<Any>.none as Any) }
    func encode(_ value: Bool) throws { throw self.fail(with: value) }
    func encode(_ value: String) throws { throw self.fail(with: value) }
    func encode(_ value: Double) throws { throw self.fail(with: value) }
    func encode(_ value: Float) throws { throw self.fail(with: value) }
    func encode(_ value: Int) throws { throw self.fail(with: value) }
    func encode<T>(_ value: T) throws where T : Encodable { throw self.fail(with: value) }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        let container = AsyncKeyedEncoder<NestedKey>(path: self.codingPath, encoder: self.encoder)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return AsyncUnkeyedEncoder(encoder: self.encoder)
    }
    
    func superEncoder() -> Encoder {
        return encoder
    }
}
