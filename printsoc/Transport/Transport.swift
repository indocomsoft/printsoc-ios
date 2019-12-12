//
//  Transport.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation

typealias DefaultTransport = NMSSHTransport

protocol Transport {
    associatedtype Session: TransportSession

    /// Tries to authenticate using the provided credential on a background thread
    static func authenticate(username: String, password: String) -> AnyPublisher<Session,
                                                                                 TransportError>
}
