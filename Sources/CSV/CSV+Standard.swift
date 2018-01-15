import Bits

extension CSV {
    // Might seem a bit extraneous, but it is ~twice as fast as the original implimentation:
    // https://github.com/skelpo/CSV/blob/cf98d15766b320ef6ced1e1096f48858dc4119e7/Sources/CSV/CSV.swift#L32-L53
    internal static func standardParse(_ bytes: Bytes) -> [Column] {
        var index: Int = 0
        var columnIndex: Int = 0
        let count: Int = bytes.count
        
        var columns: [Column] = []
        var stack: Bytes = []
        
        while true {
            let character = bytes[index]
            if character == .comma  {
                columns.append(Column(header: stack.makeString(), fields: []))
                stack = []
            } else if character == .newLine {
                columns.append(Column(header: stack.makeString(), fields: []))
                stack = []
                index += 1
                break
            } else {
                stack.append(character)
            }
            
            index += 1
        }
        
        while index < count {
            let character = bytes[index]
            if character == .comma || character == .newLine {
                if stack == [] {
                    columns[columnIndex].fields.append(nil)
                } else {
                    columns[columnIndex].fields.append(stack.makeString())
                }
                
                columnIndex = character == .comma ? columnIndex + 1 : 0
                stack = []
            } else {
                stack.append(character)
            }
            
            index += 1
        }
        
        return columns
    }
}
