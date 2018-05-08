import Foundation

extension Data {
    var int: Int? {
        let count: Int = self.count
        var result: Int = 0
        
        let direction: Int
        var iterator: Int
        
        if self.first == .hyphen {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case .zero: result = result &* 10
            case .one: result = (result &* 10) &+ 1
            case .two: result = (result &* 10) &+ 2
            case .three: result = (result &* 10) &+ 3
            case .four: result = (result &* 10) &+ 4
            case .five: result = (result &* 10) &+ 5
            case .six: result = (result &* 10) &+ 6
            case .seven: result = (result &* 10) &+ 7
            case .eight: result = (result &* 10) &+ 8
            case .nine: result = (result &* 10) &+ 9
            default: return nil
            }
            
            iterator += 1
        }
        
        return result &* direction
    }
    
    var float: Float? {
        let count: Int = self.count
        var result: Int = 0
        var decimal: Float = 1
        
        let direction: Int
        var iterator: Int
        
        if self.first == .hyphen {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case .zero: result = result &* 10
            case .one: result = (result &* 10) &+ 1
            case .two: result = (result &* 10) &+ 2
            case .three: result = (result &* 10) &+ 3
            case .four: result = (result &* 10) &+ 4
            case .five: result = (result &* 10) &+ 5
            case .six: result = (result &* 10) &+ 6
            case .seven: result = (result &* 10) &+ 7
            case .eight: result = (result &* 10) &+ 8
            case .nine: result = (result &* 10) &+ 9
            case .period: decimal = pow(10, Float(count - 1 - iterator))
            default: return nil
            }
            
            iterator += 1
        }
        
        return Float(result &* direction) / decimal
    }
    
    var double: Double? {
        let count: Int = self.count
        var result: Int = 0
        var decimal: Double = 1
        
        let direction: Int
        var iterator: Int
        
        if self.first == .hyphen {
            iterator = self.startIndex + 1
            direction = -1
        } else {
            iterator = self.startIndex
            direction = 1
        }
        
        while iterator < count {
            switch self[iterator]  {
            case .zero: result = result &* 10
            case .one: result = (result &* 10) &+ 1
            case .two: result = (result &* 10) &+ 2
            case .three: result = (result &* 10) &+ 3
            case .four: result = (result &* 10) &+ 4
            case .five: result = (result &* 10) &+ 5
            case .six: result = (result &* 10) &+ 6
            case .seven: result = (result &* 10) &+ 7
            case .eight: result = (result &* 10) &+ 8
            case .nine: result = (result &* 10) &+ 9
            case .period: decimal = pow(10, Double(count - 1 - iterator))
            default: return nil
            }
            
            iterator += 1
        }
        
        return Double(result &* direction) / decimal
    }
}
