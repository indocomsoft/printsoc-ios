//
//  NMSSHTransportSession.swift
//  printsoc
//
//  Created by Julius on 12/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation
import NMSSH

struct NMSSHTransportSession: TransportSession {
    let session: NMSSHSession

    func execute(command: String, requestPty: Bool) -> AnyPublisher<String, TransportSessionError> {
        Future<String, TransportSessionError> { promise in
            let channel = self.session.channel
            channel.requestPty = requestPty
            var error: NSError?
            let result = channel.execute(command, error: &error, timeout: 5)
            if let result = result {
                return promise(.success(result))
            } else {
                return promise(self.handleError(error))
            }
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .eraseToAnyPublisher()
    }

    func getFullName(for username: String) -> AnyPublisher<String, TransportSessionError> {
        execute(command: "getent passwd \(username) | cut -d ':' -f 5", requestPty: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
            .eraseToAnyPublisher()
    }

    func getPaperUsage() -> AnyPublisher<PaperUsage, TransportSessionError> {
        let command = "/usr/local/bin/pusage"

        return execute(command: command, requestPty: true)
            .flatMap { pusageOutput -> AnyPublisher<PaperUsage, TransportSessionError> in
                guard let pusage = PaperUsage(pusageOutput: pusageOutput) else {
                    return Fail(error: TransportSessionError.parsingError(command: command))
                        .eraseToAnyPublisher()
                }
                return Just(pusage)
                    .setFailureType(to: TransportSessionError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func handleError(_ error: NSError?) -> Result<String, TransportSessionError> {
        guard let error = error,
            let channelError = NMSSHChannelError(rawValue: error.code)
        else {
            fatalError("Bug in NMSSH: invalid error")
        }
        switch channelError {
        case .allocationError, .requestPtyError, .executionResponseError,
             .requestShellError, .writeError, .readError:
            return .failure(.transportLayerError(description: error.localizedDescription))
        case .executionTimeout:
            return .failure(.timeout)
        case .executionError:
            return .failure(.executionError(exitCode: Int(error.localizedFailureReason ?? "256") ?? 256,
                                            message: error.localizedDescription))
        @unknown default:
            return .failure(
                .transportLayerError(description: "Unknown error code \(error.code): \(error.description)")
            )
        }
    }
}
