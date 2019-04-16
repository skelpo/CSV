public final class CSVCodingOptions {
    public static let `default` = CSVCodingOptions(boolCodingStrategy: .string, nilCodingStrategy: .blank)

    public var boolCodingStrategy: BoolCodingStrategy
    public var nilCodingStrategy: NilCodingStrategy

    public init(boolCodingStrategy: BoolCodingStrategy, nilCodingStrategy: NilCodingStrategy) {
        self.boolCodingStrategy = boolCodingStrategy
        self.nilCodingStrategy = nilCodingStrategy
    }
}

public enum BoolCodingStrategy: Hashable {
    case integer
    case string
    case custom(`true`: [UInt8],`false`: [UInt8])

    public func bytes(from bool: Bool) -> [UInt8] {
        switch self {
        case .integer: return bool ? "1" : "0"
        case .string: return bool ? "true" : "false"
        case let .custom(`true`, `false`): return bool ? `true` : `false`
        }
    }

    public func bool(from bytes: [UInt8]) -> Bool? {
        switch (self, bytes) {
        case (.integer, ["0"]): return false
        case (.integer, ["1"]): return true
        case (.string, "false"): return false
        case (.string, "true"): return true
        case (let .custom(`true`, `false`), _):
            switch bytes {
            case `false`: return false
            case `true`: return true
            default: return nil
            }
        default: return nil
        }
    }
}

public enum NilCodingStrategy: Hashable {
    case blank
    case na
    case custom([UInt8])

    public func bytes() -> [UInt8] {
        switch self {
        case .na: return "N/A"
        case .blank: return []
        case let .custom(bytes): return bytes
        }
    }

    public func isNull(_ bytes: [UInt8]) -> Bool {
        switch (self, bytes) {
        case (.na, "N/A"): return true
        case (.blank, []): return true
        case (let .custom(expected), _): return expected == bytes
        default: return false
        }
    }
}
