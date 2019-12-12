//
//  NMSSHTransport.swift
//  printsoc
//
//  Created by Julius on 11/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation
import NMSSH

enum NMSSHTransport: Transport {
    typealias Session = NMSSHTransportSession

    static func authenticate(username: String, password: String) -> AnyPublisher<Session,
                                                                                 TransportError> {
        Deferred {
            Future<Session, TransportError> { promise in
                let session = NMSSHSession.connect(toHost: TransportConstants.host,
                                                   withUsername: username)
                guard session.isConnected else {
                    return promise(.failure(.noConnection))
                }
                session.authenticate(byPassword: password)
                guard session.isAuthorized else {
                    return promise(.failure(.unauthorized))
                }
                return promise(.success(NMSSHTransportSession(session: session)))
            }
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .eraseToAnyPublisher()
    }
}
