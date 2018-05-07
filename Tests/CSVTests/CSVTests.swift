import Bits
import XCTest
@testable import CSV

class CSVTests: XCTestCase {
    func testSpeed() {
        do {
            let url = URL(string: "file:/Users/calebkleveter/Development/Fielding.csv")!
            let data = try Data(contentsOf: url)
            
            print("Start")
            
            measure {
                let _: [CSV.Column] = CSV.parse(data)
            }
            
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testRowSpeed() {
        do {
            let url = URL(string: "file:/Users/calebkleveter/Development/Fielding.csv")!
            let data = try Data(contentsOf: url)
            
            let csv: [String: [String?]] = CSV.parse(data)
            
            let next = csv.makeRows()
            
            measure {
                while let _ = next() {}
            }
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCSVDecode()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/Fielding.csv")!
        let data = try Data(contentsOf: url)
        let fielders = try CSVCoder.decode(data, to: Fielder.self)
        XCTAssertEqual(fielders[0], Fielder(playerID: "abercda01", yearID: 1871, teamID: "TRO"))
    }
    
    func testCSVColumnSeralization()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/Fielding.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        let _ = parsed.seralize()
    }
    
    func testCSVColumnSeralizationSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/Fielding.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        
        measure {
            _ = parsed.seralize()
        }
    }
    
    static var allTests = [
        ("testSpeed", testSpeed),
        ("testRowSpeed", testRowSpeed),
        ("testCSVDecode", testCSVDecode),
        ("testCSVColumnSeralization", testCSVColumnSeralization),
        ("testCSVColumnSeralizationSpeed", testCSVColumnSeralizationSpeed)
    ]
}

struct Fielder: Decodable, Equatable {
    let playerID: String
    let yearID: Int
    let teamID: String
}
