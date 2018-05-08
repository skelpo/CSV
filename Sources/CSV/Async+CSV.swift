import Foundation
import Async

extension Future where T == Data {
    public func parseCSV() -> Future<[CSV.Column]> {
        return self.map(to: [CSV.Column].self) { (data) in
            return CSV.parse(data)
        }
    }
    
    public func parseCSV() -> Future<[String: CSV.Column]> {
        return self.map(to: [String: CSV.Column].self) { (data) in
            return CSV.parse(data)
        }
    }
    
    public func parseCSV() -> Future<[String: [String?]]> {
        return self.map(to: [String: [String?]].self) { (data) in
            return CSV.parse(data)
        }
    }
    
    public func csvTo<T>(_ type: T.Type, stringEncoding: String.Encoding = .utf8) -> Future<[T]> where T: Decodable {
        return self.map(to: [T].self) { (data) in
            return try _CSVDecoder.decode(T.self, from: data, stringDecoding: stringEncoding)
        }
    }
}
