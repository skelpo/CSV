import Bits

extension CSV {
    // Might seem a bit extraneous, but it is ~twice as fast as the original implimentation:
    // https://github.com/skelpo/CSV/blob/cf98d15766b320ef6ced1e1096f48858dc4119e7/Sources/CSV/CSV.swift#L32-L53
    internal static func standardParse(_ bytes: Bytes) -> [Column] {
        var index: Int = 0
        var columnIndex: Int = 0
        let count: Int = bytes.count
        
        var columns: [Column] = []
        var stack: Stack = []
        
        while true {
            let character = bytes[index]
            if character == .comma  {
                columns.append(Column(header: stack.release(), fields: []))
            } else if character == .newLine {
                columns.append(Column(header: stack.release(), fields: []))
                index += 1
                break
            } else {
                stack.push(character)
            }
            
            index += 1
        }
        
        while index < count {
            let character = bytes[index]
            if character == .comma || character == .newLine {
                if stack == [] {
                    columns[columnIndex].fields.append(nil)
                } else {
                    columns[columnIndex].fields.append(stack.release())
                }
                
                columnIndex = character == .comma ? columnIndex + 1 : 0
            } else {
                stack.push(character)
            }
            
            index += 1
        }
        
        return columns
    }
}
