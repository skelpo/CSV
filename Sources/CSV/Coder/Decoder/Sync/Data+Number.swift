import Foundation

extension Array where Element == UInt8 {
    var int: Int? {
        let count: Int = self.endIndex
        var result: Int = 0
        
        let direction: Int
        var iterator: Int
        
        if self.first == "-" {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case "0": result = result * 10
            case "1": result = (result * 10) + 1
            case "2": result = (result * 10) + 2
            case "3": result = (result * 10) + 3
            case "4": result = (result * 10) + 4
            case "5": result = (result * 10) + 5
            case "6": result = (result * 10) + 6
            case "7": result = (result * 10) + 7
            case "8": result = (result * 10) + 8
            case "9": result = (result * 10) + 9
            case ",": break
            default: return nil
            }
            
            iterator += 1
        }
        
        return result &* direction
    }
    
    var float: Float? {
        let count: Int = self.endIndex
        var result: Int = 0
        var decimal: Float = 1
        
        let direction: Int
        var iterator: Int
        
        if self.first == "-" {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case "0": result = result * 10
            case "1": result = (result * 10) + 1
            case "2": result = (result * 10) + 2
            case "3": result = (result * 10) + 3
            case "4": result = (result * 10) + 4
            case "5": result = (result * 10) + 5
            case "6": result = (result * 10) + 6
            case "7": result = (result * 10) + 7
            case "8": result = (result * 10) + 8
            case "9": result = (result * 10) + 9
            case ".": decimal = pow(10, Float(count - 1 - iterator))
            case ",": break
            default: return nil
            }
            
            iterator += 1
        }
        
        return Float(result &* direction) / decimal
    }
    
    var double: Double? {
        let count: Int = self.endIndex
        var result: Int = 0
        var decimal: Double = 1
        
        let direction: Int
        var iterator: Int
        
        if self.first == "-" {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case "0": result = result * 10
            case "1": result = (result * 10) + 1
            case "2": result = (result * 10) + 2
            case "3": result = (result * 10) + 3
            case "4": result = (result * 10) + 4
            case "5": result = (result * 10) + 5
            case "6": result = (result * 10) + 6
            case "7": result = (result * 10) + 7
            case "8": result = (result * 10) + 8
            case "9": result = (result * 10) + 9
            case ".": decimal = pow(10, Double(count - 1 - iterator))
            case ",": break
            default: return nil
            }
            
            iterator += 1
        }
        
        return Double(result &* direction) / decimal
    }
}
