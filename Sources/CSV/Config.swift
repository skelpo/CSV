//
//  Config.swift
//  CSV
//
//  Created by 10.19 on 5/11/19.
//

/// Wraps the Configuration options for Parse/Encode/Decode
public struct Config {
    public let delimiter: Character
    public let inQuotes: Bool
    public let enclosingCharacter: Character // Should this be called fieldWrapper?
    
    public init(delimiter: Character = ",", inQuotes: Bool = true, enclosingCharacter: Character = "\"") {
        self.delimiter = delimiter
        self.inQuotes = inQuotes
        self.enclosingCharacter = enclosingCharacter
    }
}
