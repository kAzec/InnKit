//
//  Extensions.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

extension URL {
    var removingLeadingSchemeAndWWW: URL {
        return (self as NSURL).resourceSpecifier.flatMap { s in
            if s.hasPrefix("//www.") {
                return URL(string: String(s.dropFirst(6)))
            } else if s.hasPrefix("//") {
                return URL(string: String(s.dropFirst(2)))
            } else {
                return URL(string: s)
            }
        } ?? self
    }
}

extension CodingUserInfoKey {
    init(_ rawValue: String) {
    #if swift(>=5.0)
        self = unsafeBitCast(rawValue, to: CodingUserInfoKey.self)
    #else
        self.rawValue = rawValue
    #endif
    }
}
