extension DecodingError {
    static func unableToExtract<T>(type: T.Type, at path: CodingPath) -> DecodingError {
        return DecodingError.typeMismatch(type, Context(codingPath: path, debugDescription: "Unable to extract type '\(type)' from string"))
    }
    
    static func badKey(_ key: CodingKey, at path: CodingPath) -> DecodingError {
        return DecodingError.keyNotFound(key, Context(codingPath: path, debugDescription: "Could not find column '\(key.stringValue)' in CSV"))
    }
    
    static func nilKey<T>(_ key: CodingKey, type: T.Type, at path: CodingPath) -> DecodingError {
        return DecodingError.valueNotFound(type, Context(codingPath: path, debugDescription: "Cell in column \(key.stringValue) not populated"))
    }
}
