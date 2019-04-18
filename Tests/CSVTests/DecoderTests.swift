import XCTest
import CSV

final class DecoderTests: XCTestCase {
    func testAsyncDecode() throws {
        var people: [Person] = []
        let contentLength = chunks.reduce(0) { $0 + $1.count }
        let decoder = CSVDecoder().async(for: Person.self, length: contentLength) { person in
            people.append(person)
        }

        for chunk in chunks.map({ Array($0.utf8) }) {
            try decoder.decode(chunk)
        }

        XCTAssertEqual(people.count, 6)

        XCTAssertEqual(people[0], Person(firstName: "Caleb", lastName: "Kleveter", age: 18, gender: .male, tagLine: "😜"))
        XCTAssertEqual(people[1], Person(
            firstName: "Benjamin",
            lastName: "Franklin",
            age: 269,
            gender: .male,
            tagLine: "A penny saved is a penny earned"
        ))
        XCTAssertEqual(people[2], Person(firstName: "Doc", lastName: "Holliday", age: 174, gender: .male, tagLine: "Bang"))
        XCTAssertEqual(people[3], Person(firstName: "Grace", lastName: "Hopper", age: 119, gender: .female, tagLine: nil))
        XCTAssertEqual(people[4], Person(
            firstName: "Anne",
            lastName: "Shirley",
            age: 141,
            gender: .female,
            tagLine: "God's in His heaven,\nall's right with the world"
        ))
        XCTAssertEqual(people[5], Person(firstName: "TinTin", lastName: nil, age: 16, gender: .male, tagLine: "Great snakes!"))
    }

    func testAsyncDecodeSpeed() throws {
        let bytes = chunks.map { Array($0.utf8) }
        let contentLength = chunks.reduce(0) { $0 + $1.count }

        measure {
            for _ in 0..<1_000 {
                let decoder = CSVDecoder().async(for: Person.self, length: contentLength) { _ in return }
                do {
                    try bytes.forEach(decoder.decode)
                } catch let error as DecodingError {
                    XCTFail(error.failureReason ?? "No failure reason")
                    error.errorDescription.map { print($0) }
                    error.recoverySuggestion.map { print($0) }
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }

    func testSyncDecode() throws {
        let decoder = CSVDecoder().sync
        let people = try decoder.decode(Person.self, from: Data(data.utf8))

        XCTAssertEqual(people.count, 6)

        XCTAssertEqual(people[0], Person(firstName: "Caleb", lastName: "Kleveter", age: 18, gender: .male, tagLine: "😜"))
        XCTAssertEqual(people[1], Person(
            firstName: "Benjamin",
            lastName: "Franklin",
            age: 269,
            gender: .male,
            tagLine: "A penny saved is a penny earned"
        ))
        XCTAssertEqual(people[2], Person(firstName: "Doc", lastName: "Holliday", age: 174, gender: .male, tagLine: "Bang"))
        XCTAssertEqual(people[3], Person(firstName: "Grace", lastName: "Hopper", age: 119, gender: .female, tagLine: nil))
        XCTAssertEqual(people[4], Person(
            firstName: "Anne",
            lastName: "Shirley",
            age: 141,
            gender: .female,
            tagLine: "God's in His heaven,\nall's right with the world"
        ))
        XCTAssertEqual(people[5], Person(firstName: "TinTin", lastName: nil, age: 16, gender: .male, tagLine: "Great snakes!"))
    }

    func testSyncDecodeSpeed() throws {
        let csv = Data(data.utf8)

        measure {
            for _ in 0..<1_000 {
                let decoder = CSVDecoder().sync
                do {
                    _ = try decoder.decode(Person.self, from: csv)
                } catch let error as DecodingError {
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

fileprivate let data = """
first name,last_name,age,gender,tagLine
Caleb,Kleveter,18,M,😜\r
Benjamin,Franklin,269,M,A penny saved is a penny earned
"Doc","Holliday","174","M",Bang\r
Grace,Hopper,119,F,
Anne,Shirley,141,F,"God's in His heaven,
all's right with the world"
TinTin,,16,M,Great snakes!
"""

fileprivate let chunks: [String] = [
    "first name,last_name,age",
    ",gender,tagLine\nCaleb,Kleveter,18,M,",
    "😜\r\nBenjamin,Franklin,269,M,A penny saved is a ",
    "penny earned\n\"",
    #"Doc","Holliday","174","M",Bang\#r\#n"#,
    "Grace,Hopper,119,F,",
    #"\#nAnne,Shirley,141,F,"God's in His heaven,\#n"#,
    #"all's right with the world""#,
    "\nTinTin,,16,M,Great snakes!"
]
