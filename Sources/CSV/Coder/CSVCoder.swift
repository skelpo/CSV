import Foundation

public final class CSVCoder {
    public static func decode<T>(_ data: Data, to type: T.Type = T.self)throws -> [T] where T: Decodable {
        return try _CSVDecoder.decode(T.self, from: data)
    }
    
    public static func encode<T>(_ objects: [T], boolEncoding: BoolEncodingStrategy = .toString, stringEncoding: String.Encoding = .utf32)throws -> Data where T: Encodable {
        return try Data(_CSVEncoder.encode(objects, boolEncoding: boolEncoding, stringEncoding: stringEncoding))
    }
}

public final class CSVDecoder {
    public var decodingOptions: CSVCodingOptions

    public init(decodingOptions: CSVCodingOptions = .default) {
        self.decodingOptions = decodingOptions
    }

    public var sync: CSVSyncDecoder {
        return CSVSyncDecoder()
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
    internal init() { }

    public func decode<D>(_ type: D.Type = D.self, from data: Data)throws -> [D] where D: Decodable {
        var result: [D] = []
        result.reserveCapacity(data.lazy.split(separator: "\n").count)

        let decoder = _CSVAsyncDecoder(decoding: type, path: [], decodingOptions: .default) { decoded in
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
