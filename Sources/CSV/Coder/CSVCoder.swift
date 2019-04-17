import Foundation

public final class CSVCoder {
    public var decodingOptions: CSVCodingOptions
    public var encodingOptions: CSVCodingOptions

    public init(decodingOptions: CSVCodingOptions = .default, encodingOptions: CSVCodingOptions = .default) {
        self.decodingOptions = decodingOptions
        self.encodingOptions = encodingOptions
    }

    public func decode<T>(_ data: Data, to type: T.Type = T.self)throws -> [T] where T: Decodable {
        return try _CSVDecoder(csv: Array(data), decodingOptions: self.decodingOptions).decode(T.self, from: data)
    }

    public func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        return try Data(_CSVEncoder.encode(objects, encodingOptions: self.encodingOptions))
    }
}

public final class CSVEncoder {
    public var encodingOptions: CSVCodingOptions

    public init(encodingOptions: CSVCodingOptions) {
        self.encodingOptions = encodingOptions
    }

    public var sync: CSVSyncEncoder {
        return CSVSyncEncoder(encodingOptions: self.encodingOptions)
    }

    public func async(_ onRow: @escaping ([UInt8]) -> ()) -> CSVAsyncEncoder {
        return CSVAsyncEncoder(encodingOptions: self.encodingOptions, onRow: onRow)
    }
}

public final class CSVSyncEncoder {
    internal var encodingOptions: CSVCodingOptions

    internal init(encodingOptions: CSVCodingOptions) {
        self.encodingOptions = encodingOptions
    }

    public func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        var rows: [[UInt8]] = []
        rows.reserveCapacity(objects.count)

        let encoder = AsyncEncoder(encodingOptions: self.encodingOptions) { row in
            rows.append(row)
        }
        try objects.forEach(encoder.encode)

        return Data(rows.joined(separator: [CSV.Delimiter.newLine]))
    }
}

public final class CSVAsyncEncoder {
    internal var encodingOptions: CSVCodingOptions
    private var encoder: AsyncEncoder

    internal init(encodingOptions: CSVCodingOptions, onRow: @escaping ([UInt8]) -> ()) {
        self.encodingOptions = encodingOptions
        self.encoder = AsyncEncoder(encodingOptions: encodingOptions, onRow: onRow)
    }

    public func encode<T>(_ object: T)throws where T: Encodable {
        try self.encoder.encode(object)
    }
}

public final class CSVDecoder {
    public var decodingOptions: CSVCodingOptions

    public init(decodingOptions: CSVCodingOptions = .default) {
        self.decodingOptions = decodingOptions
    }

    public var sync: CSVSyncDecoder {
        return CSVSyncDecoder(decodingOptions: self.decodingOptions)
    }

    public func async<D>(for: D.Type = D.self, length: Int, _ onInstance: @escaping (D) -> ()) -> CSVAsyncDecoder
        where D: Decodable
    {
        return CSVAsyncDecoder(
            decoding: D.self,
            onInstance: onInstance,
            length: length,
            decodingOptions: self.decodingOptions
        )
    }
}

public final class CSVSyncDecoder {
    internal var decodingOptions: CSVCodingOptions

    internal init(decodingOptions: CSVCodingOptions) {
        self.decodingOptions = decodingOptions
    }

    public func decode<D>(_ type: D.Type = D.self, from data: Data)throws -> [D] where D: Decodable {
        var result: [D] = []
        result.reserveCapacity(data.lazy.split(separator: "\n").count)

        let decoder = _CSVAsyncDecoder(decoding: type, path: [], decodingOptions: self.decodingOptions) { decoded in
            guard let typed = decoded as? D else {
                assertionFailure("Passed incompatible value into decoding completion callback")
                return
            }

            result.append(typed)
        }
        try decoder.decode(Array(data), length: data.count)

        return result
    }
}

public final class CSVAsyncDecoder {
    internal var length: Int
    internal var decoding: Decodable.Type
    internal var decodingOptions: CSVCodingOptions
    private var rowDecoder: _CSVAsyncDecoder

    internal init<D>(decoding: D.Type, onInstance: @escaping (D) -> (), length: Int, decodingOptions: CSVCodingOptions)
        where D: Decodable
    {
        let callback = { (decoded: Decodable) in
            guard let typed = decoded as? D else {
                assertionFailure("Passed incompatible value into decoding completion callback")
                return
            }
            onInstance(typed)
        }

        self.length = length
        self.decoding = decoding
        self.decodingOptions = decodingOptions
        self.rowDecoder = _CSVAsyncDecoder(
            decoding: D.self,
            path: [],
            decodingOptions: decodingOptions,
            onInstance: callback
        )

        rowDecoder.onInstance = callback
    }

    public func decode<C>(_ data: C)throws where C: Collection, C.Element == UInt8 {
        try self.rowDecoder.decode(Array(data), length: self.length)
    }
}
