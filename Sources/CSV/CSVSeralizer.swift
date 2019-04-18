import Foundation

public protocol BytesRepresentable {
    var bytes: [UInt8] { get }
}

extension String: BytesRepresentable {
    public var bytes: [UInt8] {
        return Array(self.utf8)
    }
}

extension Array: BytesRepresentable where Element == UInt8 {
    public var bytes: [UInt8] {
        return self
    }
}

extension Optional: BytesRepresentable where Wrapped: BytesRepresentable {
    public var bytes: [UInt8] {
        return self?.bytes ?? []
    }
}

public struct Serializer {
    private var serializedHeaders: Bool
    public var onRow: ([UInt8])throws -> ()

    public init(onRow: @escaping ([UInt8])throws -> ()) {
        self.serializedHeaders = false
        self.onRow = onRow
    }

    @discardableResult
    public mutating func serialize<Key, Value>(_ data: Dictionary<Key, Value>) -> Result<Void, ErrorList> where
        Key: BytesRepresentable, Value: Collection, Value.Element: BytesRepresentable, Value.Index: Strideable,
        Value.Index.Stride: SignedInteger
    {
        var errors = ErrorList()
        guard data.count > 0 else { return errors.result }

        if !self.serializedHeaders {
            let headers = data.keys.map { title in Array([[CSV.Delimiter.quote], title.bytes, [CSV.Delimiter.quote]].joined()) }
            do { try self.onRow(Array(headers.joined(separator: [CSV.Delimiter.comma]))) }
            catch let error { errors.errors.append(error) }
            self.serializedHeaders = true
        }

        guard let first = data.first?.value else { return errors.result }
        (first.startIndex..<first.endIndex).forEach { index in
            let cells = data.values.map { column -> [UInt8] in
                return Array([[CSV.Delimiter.quote], column[index].bytes, [CSV.Delimiter.quote]].joined())
            }
            do { try onRow(Array(cells.joined(separator: [CSV.Delimiter.comma]))) }
            catch let error { errors.errors.append(error) }
        }

        return errors.result
    }
}

public struct SyncSerializer {
    public init () { }

    public func serialize<Key, Value>(_ data: Dictionary<Key, Value>) -> [UInt8] where
        Key: BytesRepresentable, Value: Collection, Value.Element: BytesRepresentable, Value.Index: Strideable,
        Value.Index.Stride: SignedInteger
    {
        var rows: [[UInt8]] = []
        rows.reserveCapacity(data.first?.value.count ?? 0)

        var serializer = Serializer { row in rows.append(row) }
        serializer.serialize(data)

        return Array(rows.joined(separator: [CSV.Delimiter.newLine]))
    }
}

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
