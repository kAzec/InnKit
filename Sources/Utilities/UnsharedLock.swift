//
//  UnsharedLock.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

#if DEBUG
import Foundation
public typealias UnsharedLock = NSLock
#else
import os.lock

@_fixed_layout
public struct UnsharedLock {
    @usableFromInline
    var unfairLock = os_unfair_lock()
    
    public var name: String? {
        get {
            return nil
        }
        
        set { }
    }
    
    @inlinable
    public mutating func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    @inlinable
    public mutating func `try`() -> Bool {
        return os_unfair_lock_trylock(&unfairLock)
    }
    
    @inlinable
    public mutating func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
#endif
