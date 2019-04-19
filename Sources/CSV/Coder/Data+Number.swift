import Foundation

extension Array where Element == UInt8 {
    var int: Int? {
        let count: Int = self.endIndex
        var result: Int = 0
        
        let direction: Int
        var iterator: Int
        
        if self.first == 45 {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case 48: result = result &* 10
            case 49: result = (result &* 10) &+ 1
            case 50: result = (result &* 10) &+ 2
            case 51: result = (result &* 10) &+ 3
            case 52: result = (result &* 10) &+ 4
            case 53: result = (result &* 10) &+ 5
            case 54: result = (result &* 10) &+ 6
            case 55: result = (result &* 10) &+ 7
            case 56: result = (result &* 10) &+ 8
            case 57: result = (result &* 10) &+ 9
            case 44: break
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
        
        if self.first == 45 {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case 48: result = result &* 10
            case 49: result = (result &* 10) &+ 1
            case 50: result = (result &* 10) &+ 2
            case 51: result = (result &* 10) &+ 3
            case 52: result = (result &* 10) &+ 4
            case 53: result = (result &* 10) &+ 5
            case 54: result = (result &* 10) &+ 6
            case 55: result = (result &* 10) &+ 7
            case 56: result = (result &* 10) &+ 8
            case 57: result = (result &* 10) &+ 9
            case 46: decimal = pow(10, Float(count - 1 - iterator))
            case 44: break
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
        
        if self.first == 45 {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case 48: result = result &* 10
            case 49: result = (result &* 10) &+ 1
            case 50: result = (result &* 10) &+ 2
            case 51: result = (result &* 10) &+ 3
            case 52: result = (result &* 10) &+ 4
            case 53: result = (result &* 10) &+ 5
            case 54: result = (result &* 10) &+ 6
            case 55: result = (result &* 10) &+ 7
            case 56: result = (result &* 10) &+ 8
            case 57: result = (result &* 10) &+ 9
            case 46: decimal = pow(10, Double(count - 1 - iterator))
            case 44: break
            default: return nil
            }
            
            iterator += 1
        }
        
        return Double(result &* direction) / decimal
    }
}
