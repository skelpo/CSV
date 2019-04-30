import XCTest
import CSV

final class EncoderTests: XCTestCase {
    func testAsyncEncode() throws {
        var rows: [[UInt8]] = []
        let encoder = CSVEncoder().async { row in rows.append(row) }

        for person in people {
            try encoder.encode(person)
        }

        let string = String(decoding: Array(rows.joined(separator: [10])), as: UTF8.self)
        XCTAssertEqual(string, expected)
    }

    func testMeasureAsyncEncode() {
        
        // 0.543
        measure {
            for _ in 0..<10_000 {
                let encoder = CSVEncoder().async { _ in return }
                do {
                    try people.forEach(encoder.encode)
                } catch let error as EncodingError {
                    XCTFail(error.failureReason ?? "No failure reason")
                    error.errorDescription.map { print($0) }
                    error.recoverySuggestion.map { print($0) }
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }

    func testSyncEncode() throws {
        let encoder = CSVEncoder().sync
        let data = try encoder.encode(people)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(string, expected)
    }

    func testMeasureSyncEncode() {

        // 0.621
        measure {
            for _ in 0..<10_000 {
                let encoder = CSVEncoder().sync
                do {
                    _ = try encoder.encode(people)
                } catch let error as EncodingError {
                    XCTFail(error.failureReason ?? "No failure reason")
                    error.errorDescription.map { print($0) }
                    error.recoverySuggestion.map { print($0) }
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }
}

fileprivate struct Person: Codable, Equatable {
    let firstName: String
    let lastName: String?
    let age: Int
    let gender: Gender
    let tagLine: String?

    enum Gender: String, Codable {
        case female = "F"
        case male = "M"
    }

    enum CodingKeys: String, CodingKey {
        case firstName = "first name"
        case lastName = "last_name"
        case age
        case gender
        case tagLine
    }
}

fileprivate let people = [
    Person(firstName: "Caleb", lastName: "Kleveter", age: 18, gender: .male, tagLine: "😜"),
    Person(firstName: "Benjamin", lastName: "Franklin", age: 269, gender: .male, tagLine: "A penny saved is a penny earned"),
    Person(firstName: "Doc", lastName: "Holliday", age: 174, gender: .male, tagLine: "Bang"),
    Person(firstName: "Grace", lastName: "Hopper", age: 119, gender: .female, tagLine: nil),
    Person(
        firstName: "Anne", lastName: "Shirley", age: 141, gender: .female,
        tagLine: "God's in His heaven,\nall's right with the world"
    ),
    Person(firstName: "TinTin", lastName: nil, age: 16, gender: .male, tagLine: "Great snakes!")
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
