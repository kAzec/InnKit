//
//  Channel.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

/// A type-erased live-streaming channel, can be of various platforms.
public struct Channel : Hashable {
    /// The identity of the channel.
    public let id: Identity
    
    /// The name of the channel, usually the owner's nickname/id.
    public let name: String

    /// The title of the living/lastest stream from the channel.
    public let title: String?
    
    /// The current online status of the channel.
    public let isOnline: Bool
    
    /// The date of the most recently started stream from the channel.
    public let startDate: Date?
    
    /// The URL of the channel's avatar.
    public let avatarURL: URL?
    
    /// The URL of the channel's thumbnail.
    public let thumbnailURL: URL?
    
    /// The channel's website URL.
    public var webViewURL: URL {
        return id.makeWebViewURL(online: isOnline)
    }
    
    /// The short, human-readable version of the channel's website URL.
    public var displayURL: URL {
        return id.makeDisplayURL(online: isOnline)
    }
    
    /// The URL of the channel when viewing in a corresponding app.
    public var inAppViewURL: URL? {
        return id.makeInAppViewURL(online: isOnline)
    }
    
    /// Providing a unique hash value.
    public var hashValue: Int {
        return id.hashValue
    }
    
    /// Compare the equality of two channels.
    ///
    /// - Parameters:
    ///   - lhs: A channel with a unique id.
    ///   - rhs: Another channel with a unique id.
    /// - Returns: `true` if two channel share the same id, `false` otherwise.
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id.isEqual(to: rhs.id)
    }
}
