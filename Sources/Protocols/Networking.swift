//
//  Networking.swift
//  InnKit
//
//  Created by Fengwei Liu on 2018/11/18.
//  Copyright © 2018 kAzec. All rights reserved.
//

import Foundation

public protocol Networking : AnyObject {
    func data(for url: URL) -> Future<Data, URLError>
    func data(for request: URLRequest) -> Future<Data, URLError>
}

public extension Networking {
    func data(for url: URL) -> Future<Data, URLError> {
        return data(for: URLRequest(url: url))
    }
}
