import XCTest
import CSV

final class SerializerTests: XCTestCase {
    func testSyncSerialize() {
        let serializer = SyncSerializer()
        let serialized = serializer.serialize(orderedData)
        let string = String(decoding: serialized, as: UTF8.self)

        XCTAssertEqual(string, expected)
    }

    func testMeasuerSyncSerializer() {
        let serializer = SyncSerializer()

        // 6.679
        measure {
            for _ in 0..<100_000 {
                _ = serializer.serialize(orderedData)
            }
        }
    }

    func testChunkedSerialize() throws {
        var rows: [[UInt8]] = []
        var serializer = Serializer { row in rows.append(row) }
        for chunk in orderedChunks {
            try serializer.serialize(chunk).get()
        }

        let string = String(decoding: Array(rows.joined(separator: [10])), as: UTF8.self)
        XCTAssertEqual(string, expected)
    }

    func testMeasureChunkedSerialize() {
        var serializer = Serializer { _ in return }

        // 5.896
        measure {
            for _ in 0..<100_000 {
                orderedChunks.forEach { chunk in serializer.serialize(chunk) }
            }
        }
    }
}

internal struct OrderedKeyedCollection<K, V>: KeyedCollection, ExpressibleByDictionaryLiteral where K: Hashable {
    typealias Index = Int
    typealias Element = (key: Key, value: Value)

    typealias Key = K
    typealias Keys = Array<K>

    typealias Value = V
    typealias Values = Array<V>

    private(set) var keys: Array<K>
    private(set) var values: Array<V>

    var startIndex: Int {
        return self.keys.startIndex
    }

    var endIndex: Int {
        return self.keys.endIndex
    }

    init(dictionaryLiteral elements: (Key, Value)...) {
        self.keys = elements.map { $0.0 }
        self.values = elements.map { $0.1 }
    }

    subscript(position: Int) -> (key: K, value: V) {
        get {
            return (self.keys[position], self.values[position])
        }
        set {
            self.keys[position] = newValue.key
            self.values[position] = newValue.value
        }
    }

    func index(after i: Int) -> Int {
        return self.keys.index(after: i)
    }
}
