//
//  AnyCodingKey.swift
//  LiveInnModel
//
//  Created by Fengwei Liu on 2018/05/23.
//  Copyright © 2018 Fengwei Liu. All rights reserved.
//

struct AnyCodingKey : CodingKey, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
    var stringValue: String
    var intValue: Int?
    
    init<Key : CodingKey>(_ otherKey: Key) {
        self.stringValue = otherKey.stringValue
        self.intValue = otherKey.intValue
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
    
    init(stringLiteral value: String) {
        self.stringValue = value
        self.intValue = nil
    }
    
    init(integerLiteral value: Int) {
        self.stringValue = String(value)
        self.intValue = value
    }
}

struct AnyCodingName : CodingKey, ExpressibleByStringLiteral {
    var stringValue: String
    
    var intValue: Int? {
        return nil
    }
    
    init?(intValue: Int) {
        return nil
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init(stringLiteral value: String) {
        self.stringValue = value
    }
}

struct AnyCodingIndex : CodingKey, ExpressibleByIntegerLiteral {
    var indexValue: Int
    
    var stringValue: String {
        return String(indexValue)
    }
    
    var intValue: Int? {
        return indexValue
    }
    
    init?(intValue: Int) {
        return nil
    }
    
    init?(stringValue: String) {
        if let index = Int(stringValue) {
            self.indexValue = index
        } else {
            return nil
        }
    }
    
    init(integerLiteral value: Int) {
        self.indexValue = value
    }
}
