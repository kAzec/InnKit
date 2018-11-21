//
//  Identity.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

/// A token that uniquely identifies a channel within a context.
public protocol Identity : Codable {
    /// The hash value of the identity. Conformance to Hashable is deliberately dropped to make use of the existential
    /// container.
    var hashValue: Int { get }
    
    /// Returns a url suitable for viewing the channel in the specified status in a web view.
    ///
    /// - Parameter isOnline: Whether the channel is currently online.
    /// - Returns: A url suitable for viewing the channel in a web view.
    func makeWebViewURL(online isOnline: Bool) -> URL
    
    /// Returns a url indicating the website location of the channel in the specified status.
    ///
    /// - Parameter isOnline: Whether the channel is currently online.
    /// - Returns: A short url indicating the website location of the channel.
    func makeDisplayURL(online isOnline: Bool) -> URL
    
    /// Returns a url suitable for viewing the channel in the specified status in another app.
    ///
    /// - Parameter isOnline: Whether the channel is currently online.
    /// - Returns: A url suitable for viewing the channel in another app.
    func makeInAppViewURL(online isOnline: Bool) -> URL?
    
    /// Compare the equality of two channel identities.
    ///
    /// - Parameter other: An other channel id to compare with.
    /// - Returns: `true` if two identities are referring to the same channel, `false` otherwise.
    func isEqual(to other: Identity) -> Bool
}

public extension Identity where Self : Equatable {
    func isEqual(to other: Identity) -> Bool {
        if let o = other as? Self {
            return self == o
        } else {
            return false
        }
    }
}

// MARK: - Supporting Types

/// Wrapping an identity.
public struct AnyIdentity : Hashable, Codable {
    /// Naming a type of identity.
    @_fixed_layout
    public struct TypeName : RawRepresentable, Hashable {
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public typealias DecodingMappings = [TypeName : Identity.Type]
    public typealias EncodingMappings = [ObjectIdentifier : TypeName]
    
    private struct Wrapper : Hashable, Encodable {
        let identity: Identity
        
        var hashValue: Int {
            return identity.hashValue
        }
        
        init(_ identity: Identity) {
            self.identity = identity
        }
        
        func encode(to encoder: Encoder) throws {
            try identity.encode(to: encoder)
        }
        
        static func == (lhs: Wrapper, rhs: Wrapper) -> Bool {
            return lhs.identity.isEqual(to: rhs.identity)
        }
    }
    
    /// Passing a mapping dictionary of `[AnyIdentity.TypeName : Identity.Type]` with this key to the decoder to help
    /// decoding an identity with a concrete type.
    public static let decodingMappingsUserInfoKey = CodingUserInfoKey("AnyIdentity.decodingMappings")
    
    /// Passing a mapping dictionary of `[ObjectIdentifier(Identity.Type) : AnyIdentity.TypeName]` to the encoder to
    /// help encoding an identity of arbitrary type.
    public static let encodingMappingsUserInfoKey = CodingUserInfoKey("AnyIdentity.encodingMappings")
    
    /// The identity wrapped.
    public let base: Identity
    
    /// Deserializing an identity.
    ///
    /// - Parameter decoder: The decoder that contains informations about the identity.
    /// - Throws: A `DecodingError` if something went wrong during decoding.
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let typeName = try container.decode(String.self)
        
        guard
            let mappings = decoder.userInfo[AnyIdentity.decodingMappingsUserInfoKey] as? DecodingMappings,
            let identityType = mappings[TypeName(typeName)]
        else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Unsupported identity type \(typeName)."
            )
        }
        
        self.base = try identityType.init(from: container.superDecoder())
    }
    
    /// Serializing an identity.
    ///
    /// - Parameter encoder: The encoder that will encodes the identity's value informations as well as its type
    ///                      information.
    /// - Throws: A `EncodingError` if something went wrong during encoding.
    public func encode(to encoder: Encoder) throws {
        guard
            let identityTypes = encoder.userInfo[AnyIdentity.encodingMappingsUserInfoKey] as? EncodingMappings,
            let identityName = identityTypes[ObjectIdentifier(type(of: base))]
        else {
            throw EncodingError.invalidValue(
                base, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported identity \(base).")
            )
        }
        
        var container = encoder.unkeyedContainer()
        try container.encode(identityName.rawValue)
        try container.encode(Wrapper(base))
    }
    
    /// Hashing the identity. The hashing process takes the concrete type of the wrapped identity into account.
    ///
    /// - Parameter hasher: A hasher instance to store the hash informations.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: base)))
        hasher.combine(Wrapper(base))
    }
    
    /// Compare the equality of two channel identities.
    ///
    /// - Parameter other: An other channel id to compare with.
    /// - Returns: `true` if two identities are referring to the same channel, `false` otherwise.
    public static func == (lhs: AnyIdentity, rhs: AnyIdentity) -> Bool {
        return lhs.base.isEqual(to: rhs.base)
    }
}
