//
//  TransportSessionError.swift
//  printsoc
//
//  Created by Julius on 12/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

enum TransportSessionError: Error {
    case transportLayerError(description: String)
    case timeout
    case executionError(exitCode: Int, message: String)
    case parsingError(command: String)

    var message: String {
        switch self {
        case .timeout: return "Connection timed out"
        case let .transportLayerError(description: description): return "Transport layer error: \(description)"
        case let .executionError(exitCode: exitCode): return "Execution error with exit code \(exitCode)"
        case let .parsingError(command: command): return "Parsing error: \(command)"
        }
    }
}
