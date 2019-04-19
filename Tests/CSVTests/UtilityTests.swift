@testable import CSV
import XCTest

final class UtilityTests: XCTestCase {
    let intBytes = "123,456,788,103168".unicodeScalars.map(UInt8.init(ascii:))
    let floatBytes = "123,456788.1415925".unicodeScalars.map(UInt8.init(ascii:))
    let doubleBytes = "3.1415926535897931".unicodeScalars.map(UInt8.init(ascii:))

    func testBytesToInt() {
        let int = self.intBytes.int

        XCTAssertNotNil(int)
        XCTAssertEqual(int, 123_456_788_103_168)

        XCTAssertNil(self.floatBytes.int)
        XCTAssertNil(self.doubleBytes.int)
    }

    func testMeasureBytesToInt() {

        // 0.005
        measure {
            for _ in 0..<100_000 {
                _ = self.intBytes.int
            }
        }
    }

    func testBytesToFloat() {
        XCTAssertEqual(self.intBytes.float, 123_456_788_103_168)
        XCTAssertEqual(self.floatBytes.float, 123_456_788.1415925)
        XCTAssertEqual(self.doubleBytes.float, 3.1415925)
    }

    func testMeasureBytesToFloat() {

        // 0.007
        measure {
            for _ in 0..<100_000 {
                _ = self.floatBytes.float
            }
        }
    }

    func testBytesToDouble() {
        XCTAssertEqual(self.intBytes.double, 123_456_788_103_168)
        XCTAssertEqual(self.floatBytes.double, 123_456_788.1415925)
        XCTAssertEqual(self.doubleBytes.double, 3.1415926535897931)
    }

    func testMeasureBytesToDouble() {

        // 0.007
        measure {
            for _ in 0..<100_000 {
                _ = self.doubleBytes.double
            }
        }
    }
}
