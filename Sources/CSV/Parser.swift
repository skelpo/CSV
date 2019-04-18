import Foundation

// '\n' => 10
// '\r' => 13
// '"' => 34
// ',' => 44

/// Wraps an accumulated list of errors.
public struct ErrorList: Error {

    /// A list of errors from a repeating operation.
    public var errors: [Error]

    /// Creates a new `ErrorList` instance.
    ///
    /// - Parameter errors: The initial errors to populate the `errors` array. Defaults to an empty array.
    public init(errors: [Error] = []) {
        self.errors = errors
    }

    /// A `Result` instance that wraps the current `ErrorList` as its error.
    ///
    /// If the `errors` array is empty, the `Result` instance will be a void `success` case.
    var result: Result<Void, ErrorList> {
        return self.errors.count == 0 ? .success(()) : .failure(self)
    }
}

/// A parser for streaming `CSV` data.
///
/// - Note: You should create a new `Parser` instance for each CSV document you parse.
public struct Parser {

    /// The type of handler that gets called when a header is parsed.
    ///
    /// - Parameter title: The data for the header that is parsed.
    public typealias HeaderHandler = (_ title: [UInt8])throws -> ()

    /// The type of handler that gets called when a cell is parsed.
    ///
    /// - Parameters:
    ///   - title: The header for the cell that is parsed.
    ///   - contents: The data for the cell that is parsed.
    public typealias CellHandler = (_ title: [UInt8], _ contents: [UInt8])throws -> ()

    internal enum Position {
        case headers
        case cells
    }

    private struct State {
        var headers: [[UInt8]]
        var position: Position
        var inQuotes: Bool
        var store: [UInt8]
        var headerIndex: Array<[UInt8]>.Index
        var bytesLeft: Int?

        init() {
            self.headers = []
            self.position = .headers
            self.inQuotes = false
            self.store = []
            self.headerIndex = Array<[UInt8]>().startIndex
            self.bytesLeft = nil
        }
    }

    /// The callback that is called when a header is parsed.
    public var onHeader: HeaderHandler?

    /// The callback that is called when a cell is parsed.
    public var onCell: CellHandler?

    private var state: State

    internal var currentHeader: [UInt8] {
        return self.state.headers[self.state.headerIndex % self.state.headers.count]
    }

    /// Creates a new `Parser` instance.
    ///
    /// - Parameters:
    ///   - onHeader: The callback that will be called when a header is parsed.
    ///   - onCell: The callback that will be called when a cell is parsed.
    public init(onHeader: HeaderHandler? = nil, onCell: CellHandler? = nil) {
        self.onHeader = onHeader
        self.onCell = onCell

        self.state = State()
    }

    /// Parses an arbitrary portion of a CSV document.
    ///
    /// The data passed in should be the next slice of the document directly after the previous one.
    ///
    /// When a header is parsed from the data, the data will be passed into the registered `.onHeader` callback.
    /// When a cell is parsed from the data, the header for that given cell and the cell's data will be passed into
    /// the `.onCell` callback.
    ///
    /// - Parameters:
    ///   - data: The portion of the CSV document to parse.
    ///   - length: The full content length of the document that is being parsed.
    ///
    /// - Returns: A `Result` instance that will have a `.failure` case with all the errors thrown from
    ///   the registered callbacks. If there are no errors, then the result will be a `.success` case.
    @discardableResult
    public mutating func parse(_ data: [UInt8], length: Int? = nil) -> Result<Void, ErrorList> {
        var currentCell: [UInt8] = self.state.store
        var index = data.startIndex
        var updateState = false
        var errors = ErrorList()
        var slice: (start: Int, end: Int) = (index, index)

        while index < data.endIndex {
            let byte = data[index]
            switch byte {
            case 34:
                currentCell.append(contentsOf: data[slice.start..<slice.end])
                slice = (index + 1, index + 1)
                switch self.state.inQuotes && index + 1 < data.endIndex && data[index + 1] == 34 {
                case true: index += 1
                case false: self.state.inQuotes.toggle()
                }
            case 13:
                if self.state.inQuotes {
                    slice.end += 1
                } else {
                    if index + 1 < data.endIndex, data[index + 1] == 10 {
                        index += 1
                    }
                    fallthrough
                }
            case 10:
                if self.state.inQuotes {
                    slice.end += 1
                } else {
                    if self.state.position == .headers { updateState = true }
                    fallthrough
                }
            case 44:
                if self.state.inQuotes {
                    slice.end += 1
                } else {
                    currentCell.append(contentsOf: data[slice.start..<slice.end])
                    switch self.state.position {
                    case .headers:
                        self.state.headers.append(currentCell)
                        do { try self.onHeader?(currentCell) }
                        catch let error { errors.errors.append(error) }
                    case .cells:
                        do { try self.onCell?(self.currentHeader, currentCell) }
                        catch let error { errors.errors.append(error) }
                        self.state.headerIndex += 1
                    }
                    currentCell = []
                    slice = (index + 1, index + 1)
                }
            default: slice.end += 1
            }

            if updateState { self.state.position = .cells }
            index += 1
        }

        currentCell.append(contentsOf: data[slice.start..<slice.end])
        if let length = length {
            self.state.bytesLeft =
                (self.state.bytesLeft ?? length) -
                ((self.state.store.count + data.count) - currentCell.count)

            if (self.state.bytesLeft ?? 0) > currentCell.count {
                self.state.store = currentCell
                return errors.result
            }
        }

        switch self.state.position {
        case .headers:
            self.state.headers.append(currentCell)
            do { try self.onHeader?(currentCell) }
            catch let error { errors.errors.append(error) }
        case .cells:
            do { try self.onCell?(self.currentHeader, currentCell) }
            catch let error { errors.errors.append(error) }
        }

        return errors.result
    }
}

/// A synchronous wrapper for the `Parser` type for parsing whole CSV documents at once.
public final class SyncParser {

    /// Creates a new `SyncParser` instance
    public init() {}

    /// Parses a whole CSV document at once.
    ///
    /// - Parameter data: The CSV data to parse.
    /// - Returns: A dictionary containing the parsed CSV data. The keys are the column names
    ///   and the values are the column cells. A `nil` value is an empty cell.
    public func parse(_ data: [UInt8]) -> [[UInt8]: [[UInt8]?]] {
        var results: [[UInt8]: [[UInt8]?]] = [:]
        var parser = Parser(
            onHeader: { header in
                results[header] = []
            },
            onCell: { header, cell in
                results[header, default: []].append(cell.count > 0 ? cell : nil)
            }
        )

        parser.parse(data)
        return results
    }

    /// Parses a whole CSV document at once from a `String`.
    ///
    /// - Parameter data: The CSV data to parse.
    /// - Returns: A dictionary containing the parsed CSV data. The keys are the column names
    ///   and the values are the column cells. A `nil` value is an empty cell.
    public func parse(_ data: String) -> [String: [String?]] {
        var results: [String: [String?]] = [:]
        var parser = Parser(
            onHeader: { header in
                results[String(decoding: header, as: UTF8.self)] = []
            },
            onCell: { header, cell in
                let title = String(decoding: header, as: UTF8.self)
                let contents = String(decoding: cell, as: UTF8.self)
                results[title, default: []].append(cell.count > 0 ? contents : nil)
            }
        )

        parser.parse(Array(data.utf8))
        return results
    }
}

extension CSV {
    public static func parse(_ csv: Data) -> [String: [String?]] {
        let data = Array(csv)
        let end = data.endIndex
        let estimatedRowCount = data.reduce(0) { $1 == 10 ? $0 + 1 : $0 }
        
        var columns: [(title: String, cells: [String?])] = []
        var columnIndex = 0
        var iterator = data.startIndex
        var inQuotes = false
        var cellStart = data.startIndex
        var cellEnd = data.startIndex
        
        header: while iterator < end {
            let byte = data[iterator]
            switch byte {
            case 34:
                inQuotes = !inQuotes
                cellEnd += 1
            case 10:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == 34 }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case 13:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == 34 }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                let increment = byte == 10 ? 1 : 2
                cellStart = iterator + increment
                cellEnd = iterator + increment
                iterator += increment
                break header
            default: cellEnd += 1
            }
            iterator += 1
        }
        
        while iterator < end {
            let byte = data[iterator]
            switch byte {
            case 34:
                inQuotes = !inQuotes
                cellEnd += 1
            case 10:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == 34 }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex += 1
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case 13:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == 34 }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex = 0
                let increment = byte == 10 ? 1 : 2
                cellStart = iterator + increment
                cellEnd = iterator + increment
                iterator += increment
                continue
            default: cellEnd += 1
            }
            iterator += 1
        }
        
        if cellEnd > cellStart {
            var cell = Array(data[cellStart...cellEnd-1])
            cell.removeAll { $0 == 34 }
            columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
        }
        
        return columns.reduce(into: [:]) { result, column in
            result[column.title] = column.cells
        }
    }
    
    public static func parse(_ data: Data) -> [String: Column] {
        let elements: [String: [String?]] = self.parse(data)
        
        return elements.reduce(into: [:]) { columns, element in
            columns[element.key] = Column(header: element.key, fields: element.value)
        }
    }
    
    public static func parse(_ data: Data) -> [Column] {
        let elements: [String: [String?]] = self.parse(data)
        
        return elements.reduce(into: []) { columns, element in
            columns.append(Column(header: element.key, fields: element.value))
        }
    }
}
