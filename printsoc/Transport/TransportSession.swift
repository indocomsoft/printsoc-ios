//
//  TransportSession.swift
//  printsoc
//
//  Created by Julius on 12/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation

protocol TransportSession {
    func execute(command: String, requestPty: Bool) -> AnyPublisher<String, TransportSessionError>

    func getFullName(for username: String) -> AnyPublisher<String, TransportSessionError>

    func getPaperUsage() -> AnyPublisher<PaperUsage, TransportSessionError>

    func getPrinters() -> AnyPublisher<[Printer], TransportSessionError>
}
