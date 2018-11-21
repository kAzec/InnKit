//
//  Service.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

/// An abstract interface to fetch lastest information for a channel with a given identity.
public protocol Service : AnyObject {
    associatedtype Identity : InnKit.Identity
    
    /// Fetch the lastest channel associated with the identity.
    ///
    /// - Parameter identity: The identity of the channel.
    /// - Returns: A future of the fetched channel, or a `ServiceError` if something went wrong about the fetch.
    func channel(with identity: Identity) -> Future<Channel, ServiceError>
}

/// An abstract interface to fetch lastest informations for mutiple channels at one time.
public protocol BatchService : Service {
    /// Fetch the lastest channels associated with the identities.
    ///
    /// - Parameter identities: The identities of the channels.
    /// - Returns: A future of the fetched channels, or a `ServiceError` if something went wrong about the fetch.
    func channels(with identities: [Identity]) -> Future<[Channel], ServiceError>
}

/// An error containing the informations about what went wrong when the service failed to fetch channel(s).
public struct ServiceError : CustomNSError {
    /// An enumeration containing possible codes for a `ServiceError`.
    ///
    /// - unknown: An unknown error happened.
    /// - notFound: The channel with the specified identity could not be found.
    /// - cancelled: The fetch was cancelled manually by the client.
    /// - networkError: The fetch failed due to network errors.
    /// - invalidCredentials: The fetch failed because the credential supplied is invalid.
    public enum Code : Int {
        case unknown = -1
        case notFound = -2
        case cancelled = -999
        case unavailable = -1000
        case networkError = -2000
        case invalidCredentials = -3000
    }
    
    /// The error code.
    public let code: Code
    
    /// The underlying error which caused this error, if any.
    public let underlyingError: Error?
    
    public var errorCode: Int {
        return code.rawValue
    }
    
    public var errorUserInfo: [String : Any] {
        return underlyingError.map {
            [NSUnderlyingErrorKey : $0]
        } ?? [:]
    }
}

// MARK: - Creating a `ServiceError`.

public extension ServiceError {
    /// An unknown error happened.
    static var unknown = ServiceError(code: .notFound, underlyingError: nil)
    
    /// The channel with the specified identity could not be found.
    static var notFound = ServiceError(code: .notFound, underlyingError: nil)
    
    /// The fetch was cancelled manually by the client.
    static var cancelled = ServiceError(code: .cancelled, underlyingError: nil)
    
    /// The fetch could not proceed because the service is currently unavailable.
    static var unavailable = ServiceError(code: .unavailable, underlyingError: nil)
}

