//
//  TransportError.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

enum TransportError: Error {
    case noConnection
    case unauthorized

    var message: String {
        switch self {
        case .noConnection: return "Unable to connect to \(Constants.host)"
        case .unauthorized: return "Wrong username and/or password"
        }
    }
}
