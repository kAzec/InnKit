//
//  Context.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/18.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

public final class Context {
    public let repository: Repository
    
    private var registryLock = UnsharedLock()
    private var registeredIdentities = [AnyIdentity.TypeName : IdentitySupport]()
    
    public init(repository: Repository) {
        self.repository = repository
    }
    
    func channels(with identities: [Identity]) -> Future<[Channel], ServiceError> {
        return Future()
    }
}

// MARK: - Registering Identity Types

public extension Context {
    func register<I : Identity>(_ identityType: I.Type, for name: AnyIdentity.TypeName) {
        register(IdentitySupport(type: identityType, for: name))
    }
    
    func register<S : Service>(_ identityType: S.Identity.Type, for name: AnyIdentity.TypeName, with service: S) {
        register(IdentitySupportWithService(type: identityType, for: name, with: service))
    }
    
    func register<S : BatchService>(_ identityType: S.Identity.Type, for name: AnyIdentity.TypeName, with service: S) {
        register(IdentitySupportWithBatchService(type: identityType, for: name, with: service))
    }
    
    private func register(_ support: IdentitySupport) {
        registryLock.lock()
        registeredIdentities.updateValue(support, forKey: support.name)
        registryLock.unlock()
    }
}

private extension Context {
    class IdentitySupport {
        let type: Identity.Type
        let name: AnyIdentity.TypeName
        
        var supportsFetching: Bool {
            return false
        }
        
        var supportsBatchFetching: Bool {
            return false
        }
        
        init(type: Identity.Type, for name: AnyIdentity.TypeName) {
            self.type = type
            self.name = name
        }
        
        func channel(with identity: Identity) -> Future<Channel, ServiceError> {
            return Future(result: .failure(.unavailable))
        }
        
        func channels(with identities: [Identity]) -> Future<[Channel], ServiceError> {
            return Future(result: .failure(.unavailable))
        }
    }
    
    class IdentitySupportWithService<S : Service> : IdentitySupport {
        let service: S
        
        override var supportsFetching: Bool {
            return true
        }
        
        init(type: Identity.Type, for name: AnyIdentity.TypeName, with service: S) {
            self.service = service
            super.init(type: type, for: name)
        }
        
        override func channel(with identity: Identity) -> Future<Channel, ServiceError> {
            if let i = identity as? S.Identity {
                return service.channel(with: i)
            } else {
                return super.channel(with: identity)
            }
        }
    }
    
    class IdentitySupportWithBatchService<S : BatchService> : IdentitySupportWithService<S> {
        override var supportsBatchFetching: Bool {
            return true
        }
        
        override func channels(with identities: [Identity]) -> Future<[Channel], ServiceError> {
            if let i = identities as? [S.Identity] {
                return service.channels(with: i)
            } else {
                return super.channels(with: identities)
            }
        }
    }
}
