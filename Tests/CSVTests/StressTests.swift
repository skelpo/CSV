import XCTest
import CSV

final class StressTests: XCTestCase {
    let data: Data = {
        let string: String
        if let envVar = ProcessInfo.processInfo.environment["CSV_STRESS_TEST_DATA"] { string = "file:" + envVar }
        else { string = "https://drive.google.com/uc?export=download&id=1_9On2-nsBQIw3JiY43sWbrF8EjrqrR4U" }
        print(string)
        let url = URL(string: string)!
        return try! Data(contentsOf: url)
    }()

    func testMeasureAsyncParsing() {
        var parser = Parser(onHeader: { _ in return }, onCell: { _, _ in return })
        let csv = Array(data)

        // Baseline: 4.630
        measure {
            parser.parse(csv)
        }
    }

    func testMeasureSyncParsing() {
        let parser = SyncParser()
        let csv = Array(data)

        // Baseline: 10.825
        // Time to beat: 9.142
        measure {
            _ = parser.parse(csv)
        }
    }
}
