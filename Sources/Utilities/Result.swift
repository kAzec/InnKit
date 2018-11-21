//
//  Result.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

/// A value that represents either a success or failure, capturing associated
/// values in both cases.
public enum Result<Value, Error> {
    /// A success, storing a `Value`.
    case success(Value)
    
    /// A failure, storing an `Error`.
    case failure(Error)
    
    /// The stored value of a successful `Result`. `nil` if the `Result` was a
    /// failure.
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// The stored value of a failure `Result`. `nil` if the `Result` was a
    /// success.
    public var error: Error? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
}

// MARK: - Transforming a Result

public extension Result {
    /// Evaluates the given transform closure when this `Result` instance is
    /// `.success`, passing the value as a parameter.
    ///
    /// Use the `map` method with a closure that returns a non-`Result` value.
    ///
    /// - Parameter transform: A closure that takes the successful value of the
    ///   instance.
    /// - Returns: A new `Result` instance with the result of the transform, if
    ///   it was applied.
    func map<NewValue>(_ transform: (Value) -> NewValue) -> Result<NewValue, Error> {
        switch self {
        case let .success(value):
            return .success(transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }
    
    /// Evaluates the given transform closure when this `Result` instance is
    /// `.failure`, passing the error as a parameter.
    ///
    /// Use the `mapError` method with a closure that returns a non-`Result`
    /// value.
    ///
    /// - Parameter transform: A closure that takes the failure value of the
    ///   instance.
    /// - Returns: A new `Result` instance with the result of the transform, if
    ///   it was applied.
    func mapError<NewError>(_ transform: (Error) -> NewError) -> Result<Value, NewError> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(transform(error))
        }
    }
    
    /// Evaluates the given transform closure when this `Result` instance is
    /// `.success`, passing the value as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the successful value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous error value.
    func flatMap<NewValue>(_ transform: (Value) -> Result<NewValue, Error>) -> Result<NewValue, Error> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    /// Evaluates the given transform closure when this `Result` instance is
    /// `.failure`, passing the error as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the error value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous success value.
    func flatMapError<NewError>(_ transform: (Error) -> Result<Value, NewError>) -> Result<Value, NewError> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return transform(error)
        }
    }
}

extension Result where Error : Swift.Error {
    /// Unwraps the `Result` into a throwing expression.
    ///
    /// - Returns: The success value, if the instance is a success.
    /// - Throws:  The error value, if the instance is a failure.
    public func unwrap() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

extension Result where Error == Swift.Error {
    /// Create an instance by capturing the output of a throwing closure.
    ///
    /// - Parameter throwing: A throwing closure to evaluate.
    @_transparent
    public init(_ throwing: () throws -> Value) {
        do {
            let value = try throwing()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
    
    /// Unwraps the `Result` into a throwing expression.
    ///
    /// - Returns: The success value, if the instance is a success.
    /// - Throws:  The error value, if the instance is a failure.
    public func unwrap() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
    
    /// Evaluates the given transform closure when this `Result` instance is
    /// `.success`, passing the value as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the successful value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous error value.
    public func flatMap<NewValue>(_ transform: (Value) throws -> NewValue) -> Result<NewValue, Error> {
        switch self {
        case let .success(value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Conforming to Equatable & Hashable

extension Result : Equatable where Value : Equatable, Error : Equatable { }

extension Result : Hashable where Value : Hashable, Error : Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .success(let value):
            hasher.combine(value)
            hasher.combine(Error?.none)
        case .failure(let error):
            hasher.combine(Value?.none)
            hasher.combine(error)
        }
    }
}

// MARK: - Conforming to CustomDebugStringConvertible

extension Result : CustomDebugStringConvertible {
    public var debugDescription: String {
        var output = "Result."
        
        switch self {
        case let .success(value):
            output += "success("
            debugPrint(value, terminator: "", to: &output)
        case let .failure(error):
            output += "failure("
            debugPrint(error, terminator: "", to: &output)
        }
        
        output += ")"
        return output
    }
}
