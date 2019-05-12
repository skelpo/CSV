import XCTest
import CSV

final class SerializerTests: XCTestCase {
    func testSyncSerialize() {
        let serializer = SyncSerializer(configuration: Config(cellDelimiter: 34))
        let serialized = serializer.serialize(orderedData)
        let string = String(decoding: serialized, as: UTF8.self)

        XCTAssertEqual(string, expected)
    }

    func testMeasuerSyncSerializer() {
        let serializer = SyncSerializer()

        // 5.786
        measure {
            for _ in 0..<100_000 {
                _ = serializer.serialize(data)
            }
        }
    }

    func testChunkedSerialize() throws {
        var rows: [[UInt8]] = []
        var serializer = Serializer(configuration: Config(cellDelimiter: 34)) { row in rows.append(row) }
        for chunk in orderedChunks {
            try serializer.serialize(chunk).get()
        }

        let string = String(decoding: Array(rows.joined(separator: [10])), as: UTF8.self)
        XCTAssertEqual(string, expected)
    }

    func testMeasureChunkedSerialize() {
        var serializer = Serializer { _ in return }

        // 5.504
        measure {
            for _ in 0..<100_000 {
                chunks.forEach { chunk in serializer.serialize(chunk) }
            }
        }
    }
}

fileprivate let orderedData: OrderedKeyedCollection = [
    "first name": ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"],
    "last_name": ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil],
    "age": ["18", "269", "174", "119", "141", "16"],
    "gender": ["M", "M", "M", "F", "F", "M"],
    "tagLine": [
        "😜", "A penny saved is a penny earned", "Bang", nil,
        "God's in His heaven,\nall's right with the world", "Great snakes!"
    ]
]

fileprivate let data = [
    "first name": ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"],
    "last_name": ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil],
    "age": ["18", "269", "174", "119", "141", "16"],
    "gender": ["M", "M", "M", "F", "F", "M"],
    "tagLine": [
        "😜", "A penny saved is a penny earned", "Bang", nil,
        "God's in His heaven,\nall's right with the world", "Great snakes!"
    ]
]

fileprivate let orderedChunks: [OrderedKeyedCollection<String, Array<String?>>] = [
    ["first name": ["Caleb"], "last_name": ["Kleveter"], "age": ["18"], "gender": ["M"], "tagLine": ["😜"]],
    [
        "first name": ["Benjamin"], "last_name": ["Franklin"], "age": ["269"], "gender": ["M"],
        "tagLine": ["A penny saved is a penny earned"]
    ],
    ["first name": ["Doc"], "last_name": ["Holliday"], "age": ["174"], "gender": ["M"], "tagLine": ["Bang"]],
    ["first name": ["Grace"], "last_name": ["Hopper"], "age": ["119"], "gender": ["F"], "tagLine": [nil]],
    [
        "first name": ["Anne"], "last_name": ["Shirley"], "age": ["141"], "gender": ["F"],
        "tagLine": ["God's in His heaven,\nall's right with the world"]
    ],
    ["first name": ["TinTin"], "last_name": [nil], "age": ["16"], "gender": ["M"], "tagLine": ["Great snakes!"]]
]

fileprivate let chunks = [
    ["first name": ["Caleb"], "last_name": ["Kleveter"], "age": ["18"], "gender": ["M"], "tagLine": ["😜"]],
    [
        "first name": ["Benjamin"], "last_name": ["Franklin"], "age": ["269"], "gender": ["M"],
        "tagLine": ["A penny saved is a penny earned"]
    ],
    ["first name": ["Doc"], "last_name": ["Holliday"], "age": ["174"], "gender": ["M"], "tagLine": ["Bang"]],
    ["first name": ["Grace"], "last_name": ["Hopper"], "age": ["119"], "gender": ["F"], "tagLine": [nil]],
    [
        "first name": ["Anne"], "last_name": ["Shirley"], "age": ["141"], "gender": ["F"],
        "tagLine": ["God's in His heaven,\nall's right with the world"]
    ],
    ["first name": ["TinTin"], "last_name": [nil], "age": ["16"], "gender": ["M"], "tagLine": ["Great snakes!"]]
]

fileprivate let expected = """
"first name","last_name","age","gender","tagLine"
"Caleb","Kleveter","18","M","😜"
"Benjamin","Franklin","269","M","A penny saved is a penny earned"
"Doc","Holliday","174","M","Bang"
"Grace","Hopper","119","F",""
"Anne","Shirley","141","F","God's in His heaven,
all's right with the world"
"TinTin","","16","M","Great snakes!"
"""

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
