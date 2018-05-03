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
    
    static var allTests = [
        ("testSpeed", testSpeed),
    ]
}
