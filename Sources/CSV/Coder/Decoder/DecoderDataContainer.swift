import Bits

final class DecoderDataContainer {
    var allKeys: [CodingKey]?
    let columns: [String: [Bytes?]]
    var row: [String: Bytes]!
    var cell: Bytes?
    
    private let next: () -> [String: Bytes]?
    
    init(columns: [String: [Bytes?]]) {
        self.allKeys = nil
        self.columns = columns
        self.row = nil
        self.cell = nil
        self.next = columns.makeRows()
    }
    
    func incremetRow() {
        self.row = self.next()
    }
}
