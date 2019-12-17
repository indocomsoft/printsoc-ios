//
//  PrintsocError.swift
//  printsoc
//
//  Created by Julius on 17/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

enum PrintsocError: Error {
    case strongReference
    case keychainError
    case transportError(TransportError)
    case transportSessionError(TransportSessionError)
    case parsingError

    var message: String {
        switch self {
        case let .transportError(error): return error.message
        case let .transportSessionError(error): return "Transport session error: \(error.message)"
        case .keychainError: return "Unable to perform keychain operation"
        case .strongReference: return "Unable to obtain strong reference"
        case .parsingError: return "Unable to parse"
        }
    }
}
