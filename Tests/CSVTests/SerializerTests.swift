import XCTest
import CSV

final class SerializerTests: XCTestCase {
    func testSyncSerialize() {
        let serializer = SyncSerializer()
        let serialized = serializer.serialize(data)
        let string = String(decoding: serialized, as: UTF8.self)

        let expected = """
        "first name","last_name","age","gender","tagLine"
        "Caleb","Kleveter","18","M","😜"
        "Benjamin","Franklin","269","M","A penny saved is a penny earned"
        "Doc","Holliday","174","M","Bang"
        "Grace","Hopper","119","F",""
        "Anne","Shirley","141","F","God's in His heaven,
        all's right with the world"
        "TinTin","","16","M","Great snakes!"
        """

        XCTAssertEqual(string, expected)
    }

    func testMeasuerSyncSerializer() {
        let serializer = SyncSerializer()

        // 6.268
        measure {
            for _ in 0..<100_000 {
                _ = serializer.serialize(data)
            }
        }
    }
}

fileprivate let data: OrderedKeyedCollection = [
    "first name": ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"],
    "last_name": ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil],
    "age": ["18", "269", "174", "119", "141", "16"],
    "gender": ["M", "M", "M", "F", "F", "M"],
    "tagLine": [
        "😜", "A penny saved is a penny earned", "Bang", nil,
        "God's in His heaven,\nall's right with the world", "Great snakes!"
    ]
]

//fileprivate let chunks: [OrderedKeyedCollection<String, Array<String?>] = [
//    "first name,last_name,age",
//    ",gender,tagLine\nCaleb,Kleveter,18,M,",
//    "😜\r\nBenjamin,Franklin,269,M,A penny saved is a ",
//    "penny earned\n\"",
//    #"Doc","Holliday","174","M",Bang\#r\#n"#,
//    "Grace,Hopper,119,F,",
//    #"\#nAnne,Shirley,141,F,"God's in His heaven,\#n"#,
//    #"all's right with the world""#,
//    "\nTinTin,,16,M,Great snakes!"
//]

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
