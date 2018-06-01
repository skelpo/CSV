import Foundation
import Bits

public enum BoolEncodingStrategy {
    case toInteger
    case toString
    case custom(`true`:Bytes,`false`:Bytes)
    
    public func convert(_ bool: Bool) -> Bytes {
        switch self {
        case .toInteger: return bool ? [.one] : [.zero]
        case .toString: return bool ? [.t, .r, .u, .e] : [.f, .a, .l, .s, .e]
        case let .custom(`true`, `false`): return bool ? `true` : `false`
        }
    }
}

extension CustomStringConvertible {
    var bytes: Bytes {
        return Array(self.description.utf8)
    }
}
