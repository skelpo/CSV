import Foundation

extension Array where Element == CSV.Column {
    func seralize() -> Data {
        guard let count = self.first?.fields.count else {
            return self.map { $0.header.data }.joined(separator: ",")
        }

        var index = 0
        var data: [Data] = [self.map { $0.header.data }.joined(separator: ",")]
        data.reserveCapacity((self.first?.fields.count ?? 0) + 1)
        
        while index < count {
            data.append(self.map { ($0.fields[index] ?? "").data }.joined(separator: ","))
            index += 1
        }
        
        return data.joined(separator: "\n")
    }
}

extension Dictionary where Key == String, Value == Array<String?> {
    func seralize() -> Data {
        guard let count = self.first?.value.count else {
            return self.keys.map { $0.data }.joined(separator: ",")
        }
        
        var index = 0
        var data: [Data] = [self.keys.map { $0.data }.joined(separator: ",")]
        data.reserveCapacity((self.first?.value.count ?? 0) + 1)
        
        while index < count {
            data.append(self.values.map { ($0[index] ?? "").data }.joined(separator: ","))
            index += 1
        }
        
        return data.joined(separator: "\n")
    }
}

extension String {
    var data: Data {
        return Data(self.utf8)
    }
}

extension Array where Element == Data {
    func joined(separator: UInt8) -> Element {
        let count = self.count
        var data = Data()
        var iterator = self.startIndex
        
        if self.count > 0 {
            data.append(contentsOf: self[iterator])
            iterator += 1
        }
        
        while iterator < count {
            data.append(separator)
            data.append(contentsOf: self[iterator])
            iterator += 1
        }
        
        return data
    }
}
