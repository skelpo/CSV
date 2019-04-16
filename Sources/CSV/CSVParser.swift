import Foundation

public struct ErrorList: Error {
    public var errors: [Error]

    public init(errors: [Error] = []) {
        self.errors = errors
    }

    var result: Result<Void, ErrorList> {
        return self.errors.count == 0 ? .success(()) : .failure(self)
    }
}

extension CSV {
    public struct Parser {
        public typealias HeaderHandler = (_ title: [UInt8])throws -> ()
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
        
        public var onHeader: HeaderHandler?
        public var onCell: CellHandler?
        private var state: State
        
        internal var currentHeader: [UInt8] {
            return self.state.headers[self.state.headerIndex % self.state.headers.count]
        }
        
        public init(onHeader: HeaderHandler? = nil, onCell: CellHandler? = nil) {
            self.onHeader = onHeader
            self.onCell = onCell
            
            self.state = State()
        }

        @discardableResult
        public mutating func parse(_ data: [UInt8], length: Int? = nil) -> Result<Void, ErrorList> {
            var currentCell: [UInt8] = self.state.store
            var index = data.startIndex
            var updateState = false
            var errors = ErrorList()

            while index < data.endIndex {
                let byte = data[index]
                switch byte {
                case Delimiter.quote:
                    if self.state.inQuotes, index + 1 < data.endIndex, data[index + 1] == Delimiter.quote {
                        currentCell.append(Delimiter.quote)
                        index += 1
                    } else {
                        self.state.inQuotes.toggle()
                    }
                case Delimiter.carriageReturn:
                    if self.state.inQuotes {
                        currentCell.append(Delimiter.carriageReturn)
                    } else {
                        if index + 1 < data.endIndex, data[index + 1] == Delimiter.newLine {
                            index += 1
                        }
                        fallthrough
                    }
                case Delimiter.newLine:
                    if self.state.inQuotes {
                        currentCell.append(Delimiter.newLine)
                    } else {
                        if self.state.position == .headers { updateState = true }
                        fallthrough
                    }
                case Delimiter.comma:
                    if self.state.inQuotes {
                        currentCell.append(Delimiter.comma)
                    } else {
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
                    }
                default: currentCell.append(byte)
                }
                
                if updateState { self.state.position = .cells }
                index += 1
            }
            
            if let length = length {
                if let left = self.state.bytesLeft {
                    self.state.bytesLeft = left - ((self.state.store.count + data.count) - currentCell.count)
                } else {
                    self.state.bytesLeft = length - ((self.state.store.count + data.count) - currentCell.count)
                }
                
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
    
    public struct SyncParser {
        public init() {}
        
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
        
        public func parse(_ data: String) -> [String: [String?]] {
            var results: [String: [String?]] = [:]
            var parser = Parser(
                onHeader: { header in
                    if let title = String(bytes: header, encoding: .utf8) {
                        results[title] = []
                    }
                },
                onCell: { header, cell in
                    if let title = String(bytes: header, encoding: .utf8), let contents = String(bytes: cell, encoding: .utf8) {
                        results[title, default: []].append(cell.count > 0 ? contents : nil)
                    }
                }
            )
            
            parser.parse(Array(data.utf8))
            return results
        }
    }
}

extension CSV {
    public static func parse(_ csv: Data) -> [String: [String?]] {
        let data = Array(csv)
        let end = data.endIndex
        let estimatedRowCount = data.reduce(0) { $1 == Delimiter.newLine ? $0 + 1 : $0 }
        
        var columns: [(title: String, cells: [String?])] = []
        var columnIndex = 0
        var iterator = data.startIndex
        var inQuotes = false
        var cellStart = data.startIndex
        var cellEnd = data.startIndex
        
        header: while iterator < end {
            let byte = data[iterator]
            switch byte {
            case Delimiter.quote:
                inQuotes = !inQuotes
                cellEnd += 1
            case Delimiter.comma:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == Delimiter.quote }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case Delimiter.newLine, Delimiter.carriageReturn:
                if inQuotes { cellEnd += 1; break }
                
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == Delimiter.quote }
                
                guard let title = String(bytes: cell, encoding: .utf8) else { return [:] }
                var cells: [String?] = []
                cells.reserveCapacity(estimatedRowCount)
                columns.append((title, cells))
                
                let increment = byte == Delimiter.newLine ? 1 : 2
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
            case Delimiter.quote:
                inQuotes = !inQuotes
                cellEnd += 1
            case Delimiter.comma:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == Delimiter.quote }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex += 1
                cellStart = iterator + 1
                cellEnd = iterator + 1
            case Delimiter.newLine, Delimiter.carriageReturn:
                if inQuotes { cellEnd += 1; break }
                var cell = Array(data[cellStart...cellEnd-1])
                cell.removeAll { $0 == Delimiter.quote }
                columns[columnIndex].cells.append(cell.count > 0 ? String(bytes: cell, encoding: .utf8) : nil)
                
                columnIndex = 0
                let increment = byte == Delimiter.newLine ? 1 : 2
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
            cell.removeAll { $0 == Delimiter.quote }
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
