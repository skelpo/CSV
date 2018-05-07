import Foundation
import Bits

extension Array where Element == CSV.Column {
    func seralize() -> Data {
        guard let count = self.first?.fields.count else {
            return self.map { $0.header.data }.joined(separator: .comma)
        }

        var index = 0
        var data: [Data] = [self.map { $0.header.data }.joined(separator: .comma)]
        
        while index < count {
            data.append(self.map { ($0.fields[index] ?? "").data }.joined(separator: .comma))
            index += 1
        }
        
        return data.joined(separator: .newLine)
    }
}

extension String {
    var data: Data {
        return Data(self.utf8)
    }
}

extension Array where Element == Data {
    func joined(separator: UInt8) -> Element {
        return self.reduce(into: Data()) { data, subsequence in
            if data.count > 0 { data.append(separator) }
            data.append(contentsOf: subsequence)
        }
    }
}
