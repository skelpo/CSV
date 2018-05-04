import Foundation

final class _CSVEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let data: DataContainer
    
    init(data: DataContainer, path: CodingPath = [], info: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = path
        self.userInfo = info
        self.data = data
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError()
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
    
    static func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        let encoder = _CSVEncoder(data: DataContainer())
        try objects.encode(to: encoder)
        return encoder.data.data
    }
}

final class DataContainer {
    var data: Data
    var titlesCreated: Bool
    
    init(data: Data = Data()) {
        self.data = data
        self.titlesCreated = false
    }
}
