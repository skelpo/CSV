import Foundation

extension Dictionary where Key == String, Value == Array<String?> {
    public func makeRows() -> () -> [String: String?]? {
        var rowIndex = 1
        
        func next() -> [String: String?]? {
            defer { rowIndex += 1 }
            guard let first = self.first else { return nil }
            guard rowIndex < first.value.count else { return nil }
            return self.mapValues { $0[rowIndex] }
        }
        
        return next
    }
}
