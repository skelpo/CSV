import Foundation

public final class CSVCoder {
    public static func decode<T>(_ data: Data, to type: T.Type = T.self)throws -> [T] where T: Decodable {
        return try _CSVDecoder.decode(T.self, from: data)
    }
    
    public static func encode<T>(_ objects: [T])throws -> Data where T: Encodable {
        return try _CSVEncoder.encode(objects)
    }
}
