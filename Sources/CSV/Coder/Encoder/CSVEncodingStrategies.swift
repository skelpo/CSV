import Foundation

public enum BoolEncodingStrategy {
    case toInteger
    case toString
    case custom(`true`: [UInt8],`false`: [UInt8])
    
    public func convert(_ bool: Bool) -> [UInt8] {
        switch self {
        case .toInteger: return bool ? "1" : "0"
        case .toString: return bool ? "true" : "false"
        case let .custom(`true`, `false`): return bool ? `true` : `false`
        }
    }
}
