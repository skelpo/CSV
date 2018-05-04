import Foundation
import Bits

public enum BoolEncodingStrategy {
    case toInteger
    case toString
    case custom(`true`:Data,`false`:Data)
    
    public func convert(_ bool: Bool) -> Data {
        switch self {
        case .toInteger: return bool ? Data([.one]) : Data([.zero])
        case .toString: return bool ? Data([.t, .r, .u, .e]) : Data([.f, .a, .l, .s, .e])
        case let .custom(`true`, `false`): return bool ? `true` : `false`
        }
    }
}
