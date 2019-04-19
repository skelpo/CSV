import Foundation

final class AsyncEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    let container: DataContainer
    let encodingOptions: CSVCodingOptions
    let onRow: ([UInt8]) -> ()
    
    init(
        path: [CodingKey] = [],
        info: [CodingUserInfoKey : Any] = [:],
        encodingOptions: CSVCodingOptions,
        onRow: @escaping ([UInt8]) -> ()
    ) {
        self.codingPath = path
        self.userInfo = info
        self.container = DataContainer(section: .header)
        self.encodingOptions = encodingOptions
        self.onRow = onRow
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = AsyncKeyedEncoder<Key>(path: self.codingPath, encoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return AsyncUnkeyedEncoder(encoder: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return AsyncSingleValueEncoder(path: self.codingPath, encoder: self)
    }
    
    func encode<T>(
        _ object: T
    )throws where T: Encodable {
        switch self.container.section {
        case .header:
            try object.encode(to: self)
            self.onRow(Array(self.container.cells.joined(separator: [44])))
            self.container.section = .row
            self.container.rowCount += 1
            self.container.cells = []
            fallthrough
        case .row:
            try object.encode(to: self)
            self.onRow(Array(self.container.cells.joined(separator: [44])))
            self.container.rowCount += 1
            self.container.cells = []
        }
    }

    enum EncodingSection {
        case header
        case row
    }

    final class DataContainer {
        var cells: [[UInt8]]
        var section: EncodingSection
        var rowCount: Int

        init(cells: [[UInt8]] = [], section: EncodingSection = .row) {
            self.cells = cells
            self.section = section
            self.rowCount = 0
        }
    }
}
