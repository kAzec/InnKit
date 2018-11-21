//
//  Future.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

open class Future<Value, Error> {
    public typealias Observer = (Result<Value, Error>) -> Void
    
    @usableFromInline
    enum State {
        case pending(ContiguousArray<Observer>)
        case resolved(Value)
        case rejected(Error)
        
        @usableFromInline
        init(result: Result<Value, Error>) {
            switch result {
            case .success(let value): self = .resolved(value)
            case .failure(let error): self = .rejected(error)
            }
        }
    }
    
    fileprivate final var lock = UnsharedLock()
    fileprivate final var state = State.pending(.init())
    
    @inlinable
    public init() { }
    
    public init(observer: @escaping Observer) {
        self.state = .pending([observer])
    }
    
    public init(result: Result<Value, Error>) {
        self.state = State(result: result)
    }
    
    open func observe(with observer: @escaping Observer) {
        lock.lock()
        
        switch state {
        case .pending(var observers):
            state = .pending(.init())
            observers.append(observer)
            state = .pending(observers)
            lock.unlock()
        case .resolved(let value):
            lock.unlock()
            observer(.success(value))
        case .rejected(let error):
            lock.unlock()
            observer(.failure(error))
        }
    }
    
    fileprivate func finalize(with result: Result<Value, Error>) {
        lock.lock()
        
        switch state {
        case .pending(let observers):
            self.state = State(result: result)
            lock.unlock()
            
            for observer in observers {
                observer(result)
            }
        default: lock.unlock()
        }
    }
}

open class Promise<Value, Error : Swift.Error> : Future<Value, Error> {
    @inlinable
    public convenience init(starting startHandler: (Promise) -> Void) {
        self.init()
        startHandler(self)
    }
    
    open func resolve(with value: Value) {
        finalize(with: .success(value))
    }
    
    open func reject(with error: Error) {
        finalize(with: .failure(error))
    }
}

// MARK: - Observing Values and Errors

public extension Future {
    @inlinable
    func observeValue(with observer: @escaping (Value) -> Void) {
        observe {
            if case .success(let value) = $0 {
                observer(value)
            }
        }
    }
    
    @inlinable
    func observeError(with observer: @escaping (Error) -> Void) {
        observe {
            if case .failure(let error) = $0 {
                observer(error)
            }
        }
    }
}

// MARK: - Transforming a Future

public extension Future {
    @inlinable
    func map<T>(_ transform: @escaping (Value) -> T) -> Future<T, Error> {
        return mapResult { $0.map(transform) }
    }
    
    @inlinable
    func mapError<F>(_ transform: @escaping (Error) -> F) -> Future<Value, F> {
        return mapResult { $0.mapError(transform) }
    }
    
    @inlinable
    func flatMap<T>(_ transform: @escaping (Value) -> Result<T, Error>) -> Future<T, Error> {
        return mapResult { $0.flatMap(transform) }
    }
    
    @inlinable
    func flatMapError<F>(_ transform: @escaping (Error) -> Result<Value, F>) -> Future<Value, F> {
        return mapResult { $0.flatMapError(transform) }
    }
    
    func mapResult<T, F>(_ transform: @escaping (Result<Value, Error>) -> Result<T, F>) -> Future<T, F> {
        let future: Future<T, F>
        
        lock.lock()
        switch state {
        case .pending(var observers):
            future = Future<T, F>()
            state = .pending(.init())
            
            observers.append {
                future.finalize(with: transform($0))
            }
            
            state = .pending(observers)
            lock.unlock()
        case .resolved(let value):
            lock.unlock()
            future = Future<T, F>(result: transform(.success(value)))
        case .rejected(let error):
            lock.unlock()
            future = Future<T, F>(result: transform(.failure(error)))
        }
        
        return future
    }
}
