//
//  Repository.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/18.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

public protocol Repository : AnyObject {
    /// Register a identity type for a unique name in the repository.
    ///
    /// - Parameters:
    ///   - identityType: The identity type to register.
    ///   - name: A unique name associated with the newly registered identity type.
    func register(_ identityType: Identity.Type, for name: AnyIdentity.TypeName)
    
    /// Fetch local channels.
    ///
    /// - Returns: A future of the fetched channels, or an error describing what went wrong about the fetch.
    func channels() -> Future<[Channel], Error>
    
    /// Update local channels.
    ///
    /// - Parameter channels: The new version of the channels used to update the corresponding channels stored in the
    ///   repository.
    /// - Returns: A future indicating the update completed successfully, or an error describing what went wrong about
    ///            the update.
    func update(_ channels: [Channel]) -> Future<Void, Error>
    
    /// Reorder local channels.
    ///
    /// - Parameter identities: An ordered array of channel identities, the order of which indicates the new order of
    ///                         the channels stored in the repository.
    /// - Returns: A future indicating the reorder completed successfully, or an error describing what went wrong about
    ///            the order.
    func reorder(accordingTo identities: [Identity]) -> Future<Void, Error>
}
