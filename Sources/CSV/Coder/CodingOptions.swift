/// The options used for encoding/decoding certin types in the `CSVEncoder` and `CSVDecoder`.
public final class CSVCodingOptions {

    /// The default coding options.
    ///
    /// This option set uses `.string` for the `BoolCodingStrategy` and `.blank` for
    /// the `NilCodingStrategy`. This means `Bool` will be represented the value's textual name
    /// and `nil` will be an empty cell.
    public static let `default` = CSVCodingOptions(boolCodingStrategy: .string, nilCodingStrategy: .blank)

    /// The bool encoding/decoding strategy used for the encoder/decoder the option set is passed to.
    public var boolCodingStrategy: BoolCodingStrategy

    /// The nil encoding/decoding strategy used for the encoder/decoder the option set is passed to.
    public var nilCodingStrategy: NilCodingStrategy

    /// Creates a new `CSVCodingOptions` instance.
    ///
    /// - Parameters:
    ///   - boolCodingStrategy: The bool encoding/decoding strategy used for the encoder/decoder the option set is passed to.
    ///   - nilCodingStrategy: The nil encoding/decoding strategy used for the encoder/decoder the option set is passed to.
    public init(boolCodingStrategy: BoolCodingStrategy, nilCodingStrategy: NilCodingStrategy) {
        self.boolCodingStrategy = boolCodingStrategy
        self.nilCodingStrategy = nilCodingStrategy
    }
}

/// The encoding/decodig strategies used on boolean values in a CSV document.
public enum BoolCodingStrategy: Hashable {

    /// The bools are represented by their number counter part, `false` is `0` and `true` is `1`.
    case integer

    /// The bools are represented by their textual counter parts, `false` is `"false"` and `true` is `"true"`.
    case string

    /// The bools are checked against multiple different values when they are decoded.
    /// They are encoded to their string values.
    ///
    /// When decoding data with this strategy, the characters in the data are lowercased and it is then
    /// checked against `true`, `yes`, `y`, `y`, and `1` for true and `false`, `no`, `f`, `n`, and `0` for false.
    case fuzzy

    /// A custom coding strategy with any given representations for the `true` and `false` values.
    ///
    /// - Parameters:
    ///   - true: The value that `true` gets converted to, and that `true` is represented by in the CSV document.
    ///   - false: The value that `false` gets converted to, and that `false` is represented by in the CSV document.
    case custom(`true`: [UInt8],`false`: [UInt8])

    /// Converts a `Bool` value to the bytes the reporesent it, given the current strategy.
    ///
    /// - Parameter bool: The `Bool` instance to get the bytes for.
    /// - Returns: The bytes value for the bool passed in.
    public func bytes(from bool: Bool) -> [UInt8] {
        switch self {
        case .integer: return bool ? "1" : "0"
        case .string, .fuzzy: return bool ? "true" : "false"
        case let .custom(`true`, `false`): return bool ? `true` : `false`
        }
    }

    /// Attempts get a `Bool` value from given bytes using the current strategy.
    ///
    /// - Parameter bytes: The bytes to chek against the expected value for the given strategy.
    /// - Returns: The `Bool` value for the bytes passed in, or `nil` if no match is found.
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
        case (.fuzzy, _):
            switch String(decoding: bytes, as: UTF8.self).lowercased() {
            case "true", "yes", "t", "y", "1": return true
            case "false", "no", "f", "n", "0": return false
            default: return nil
            }
        default: return nil
        }
    }
}

/// The encoding/decoding strategies used for `nil` values in a CSV document.
public enum NilCodingStrategy: Hashable {

    /// A `nil` value is represented by an empty cell.
    case blank

    /// A `nil` value is represented by `N/A` as a cell's contents.
    case na

    /// A `nil` value is represented by a custom set of bytes.
    ///
    /// - Parameter bytes: The bytes that represent `nil` in the CSV document.
    case custom(_ bytes: [UInt8])

    /// Gets the bytes that represent `nil` with the current strategy.
    ///
    /// - Returns: `nil`, represented by a byte array.
    public func bytes() -> [UInt8] {
        switch self {
        case .na: return [78, 47, 65]
        case .blank: return []
        case let .custom(bytes): return bytes
        }
    }

    /// Checks to see if a given array of bytes represents `nil` with the current strategy.
    ///
    /// - Parameter bytes: The bytes to match against the current strategy.
    /// - Returns: A `Bool` indicating whether the bytes passed in represent `nil` or not.
    public func isNull(_ bytes: [UInt8]) -> Bool {
        switch (self, bytes) {
        case (.na, [78, 47, 65]): return true
        case (.blank, []): return true
        case (let .custom(expected), _): return expected == bytes
        default: return false
        }
    }
}
