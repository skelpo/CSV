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
}
