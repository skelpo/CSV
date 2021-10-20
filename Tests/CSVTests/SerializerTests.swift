import XCTest
import CSV

final class SerializerTests: XCTestCase {
    func testSyncSerialize() {
        let serializer = SyncSerializer(configuration: Config.default)
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
        var serializer = Serializer(configuration: Config.default) { row in rows.append(row) }
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

    func testEscapedDelimiter() {
        let quoteData: OrderedKeyedCollection = ["list": ["Standard string", #"A string with "quotes""#]]
        let hashData: OrderedKeyedCollection = ["list": ["Some string without hashes", "A #string with# hashes"]]

        let quoteResult = """
        "list"
        "Standard string"
        "A string with ""quotes""\"
        """
        let hashResult = """
        #list#
        #Some string without hashes#
        #A ##string with## hashes#
        """

        let quoteSerializer = SyncSerializer()
        let hashSerializer = SyncSerializer(configuration: .init(cellSeparator: 44, cellDelimiter: 35))

        XCTAssertEqual(quoteSerializer.serialize(quoteData), Array(quoteResult.utf8))
        XCTAssertEqual(hashSerializer.serialize(hashData), Array(hashResult.utf8))
    }

    func testMismatchColumnLength() throws {
        let data: OrderedKeyedCollection = [
            "names": ["Ralph", "Caleb", "Gwynne", "Tim", "Tanner", "Logan", "Joannis"],
            "specialties": ["Manager", "Grunt", "Know-it-All", "Vapor", "Rockets"]
        ]

        let serializer = SyncSerializer()
        let result = String(decoding: serializer.serialize(data), as: UTF8.self)
        let match = """
        "names","specialties"
        "Ralph","Manager"
        "Caleb","Grunt"
        "Gwynne","Know-it-All"
        "Tim","Vapor"
        "Tanner","Rockets"
        "Logan",
        "Joannis",
        """

        XCTAssertEqual(result, match)
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
