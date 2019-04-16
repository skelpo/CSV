import CSV
import XCTest

final class ParserTests: XCTestCase {
    func testParserInit() {
        let parser = CSV.Parser(onHeader: nil, onCell: nil)
        
        XCTAssert(parser.onCell == nil)
        XCTAssert(parser.onHeader == nil)
    }
    
    func testParserParse() {
        var headers: [String] = []
        var cells: [String: [String?]] = [:]
        
        var parser = CSV.Parser(
            onHeader: { header in
                if let title = String(bytes: header, encoding: .utf8) {
                    headers.append(title)
                }
            },
            onCell: { header, cell in
                if let title = String(bytes: header, encoding: .utf8) {
                    let contents = cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil
                    cells[title, default: []].append(contents)
                }
            }
        )
        let csv = Array(data.utf8)
        
        parser.parse(csv)
        
        XCTAssertEqual(headers, ["first name", "last_name", "age", "gender", "tagLine"])
        XCTAssertEqual(cells["first name"], ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"])
        XCTAssertEqual(cells["last_name"], ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil])
        XCTAssertEqual(cells["age"], ["18", "269", "174", "119", "141", "16"])
        XCTAssertEqual(cells["gender"], ["M", "M", "M", "F", "F", "M"])
        XCTAssertEqual(cells["tagLine"], [
            "😜",
            "A penny saved is a penny earned",
            "Bang",
            nil,
            "God's in His heaven,\nall's right with the world",
            "Great snakes!"
        ])
    }
    
    func testChunkedParsing() {
        var headers: [String] = []
        var cells: [String: [String?]] = [:]
        
        var parser = CSV.Parser(
            onHeader: { header in
                if let title = String(bytes: header, encoding: .utf8) {
                    headers.append(title)
                }
            },
            onCell: { header, cell in
                if let title = String(bytes: header, encoding: .utf8) {
                    let contents = cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil
                    cells[title, default: []].append(contents)
                }
            }
        )
        
        for chunk in chunks {
            let data = Array(chunk.utf8)
            parser.parse(data, length: 270)
        }
        
        XCTAssertEqual(chunks.reduce(into: "", { $0.append($1) }), data)
        
        XCTAssertEqual(headers, ["first name", "last_name", "age", "gender", "tagLine"])
        XCTAssertEqual(cells["first name"], ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"])
        XCTAssertEqual(cells["last_name"], ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil])
        XCTAssertEqual(cells["age"], ["18", "269", "174", "119", "141", "16"])
        XCTAssertEqual(cells["gender"], ["M", "M", "M", "F", "F", "M"])
        XCTAssertEqual(cells["tagLine"], [
            "😜",
            "A penny saved is a penny earned",
            "Bang",
            nil,
            "God's in His heaven,\nall's right with the world",
            "Great snakes!"
        ])
    }
    
    func testMeasureFullParse() {
        var parser = CSV.Parser(onHeader: { _ in return }, onCell: { _, _ in return })
        let csv = Array(data.utf8)
        
        measure {
            for _ in 0..<10_000 {
                parser.parse(csv)
            }
        }
    }
    
    func testMeasureChunkedParse() {
        var parser = CSV.Parser(onHeader: { _ in return }, onCell: { _, _ in return })
        let chnks = chunks.map { Array($0.utf8) }
        let length = chnks.reduce(0) { $0 + $1.count }
        
        measure {
            for _ in 0..<10_000 {
                chnks.forEach { chunk in parser.parse(chunk, length: length) }
            }
        }
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
