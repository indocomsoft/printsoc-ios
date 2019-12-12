//
//  TransportError.swift
//  printsoc
//
//  Created by Julius on 11/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

enum TransportError: Error {
    case noConnection
    case unauthorized
    case channelError(Error)

    var message: String {
        switch self {
        case .noConnection: return "Unable to connect to \(TransportConstants.host)"
        case .unauthorized: return "Wrong username and/or password"
        case .channelError: return "Channel error"
        }
    }
}
