//
//  Twitch.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/17.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

public enum Twitch {
    static let siteURL = URL(string: "https://www.twitch.tv")!
    static let helixURL = URL(string: "https://api.twitch.tv/helix/")!
    static let krakenURL = URL(string: "https://api.twitch.tv/kraken/")!
}

// MARK: - Identifying Twitch Channels

public extension Twitch {
    struct Identity : InnKit.Identity, Hashable {
        private enum CodingKeys : String, CodingKey {
            case userID = "uid"
            case userLogin = "login"
        }
        
        public let userID: Int32
        public let userLogin: String
        
        init(userID: Int32, userLogin: String) {
            self.userID = userID
            self.userLogin = userLogin
        }
        
        public init(userID: Int32) {
            self.userID = userID
            self.userLogin = ""
        }
        
        public init(userLogin: String) {
            self.userID = -1
            self.userLogin = userLogin
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.userID = try container.decode(Int32.self, forKey: .userID)
            self.userLogin = try container.decode(String.self, forKey: .userLogin)
        }
        
        public func makeWebViewURL(online _: Bool) -> URL {
            return URL(string: userLogin, relativeTo: Twitch.siteURL) ?? Twitch.siteURL
        }
        
        public func makeDisplayURL(online isOnline: Bool) -> URL {
            return makeWebViewURL(online: isOnline).removingLeadingSchemeAndWWW
        }
        
        public func makeInAppViewURL(online isOnline: Bool) -> URL? {
            return isOnline ? URL(string: "twitch://stream/\(userLogin)") : URL(string: "twitch://channel/\(userLogin)")
        }
    }
}

// MARK: - Fetching Twitch Channels

public extension Twitch {
    final class Service : BatchService {
        let network: Networking
        let decoder: JSONDecoder
        
        let clientID: String
        
        public init(network: Networking, clientID: String) {
            self.decoder = JSONDecoder()
            self.network = network
            self.clientID = clientID
            
            decoder.dateDecodingStrategy = .iso8601
        }
        
        public func channel(with id: Twitch.Identity) -> Future<Channel, ServiceError> {
            return Future(result: .failure(.unknown))
        }
        
        public func channels(with IDs: [Twitch.Identity]) -> Future<[Channel], ServiceError> {
            return Future(result: .failure(.unknown))
        }
    }
}
