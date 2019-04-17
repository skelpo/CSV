import Foundation

final class _CSVEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let container: DataContainer
    let encodingOptions: CSVCodingOptions
    
    init(
        container: DataContainer,
        path: CodingPath = [],
        info: [CodingUserInfoKey : Any] = [:],
        encodingOptions: CSVCodingOptions
    ) {
        self.codingPath = path
        self.userInfo = info
        self.container = container
        self.encodingOptions = encodingOptions
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = _CSVKeyedEncoder<Key>(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _CSVUnkeyedEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return _CSVSingleValueEncoder(container: self.container, path: self.codingPath, encodingOptions: self.encodingOptions)
    }
    
    static func encode<T>(_ objects: [T], encodingOptions: CSVCodingOptions)throws -> [UInt8] where T: Encodable {
        let encoder = _CSVEncoder(container: DataContainer(), encodingOptions: encodingOptions)
        try objects.encode(to: encoder)
        return encoder.container.data
    }
}

final class DataContainer {
    var data: [UInt8]
    var titlesCreated: Bool
    
    init(data: [UInt8] = [], titles: Bool = false) {
        self.data = data
        self.titlesCreated = titles
    }
}
