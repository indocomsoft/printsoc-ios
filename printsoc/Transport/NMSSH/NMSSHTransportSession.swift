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
        Deferred {
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
            .subscribe(on: DispatchQueue.global(qos: .userInitiated)) // serialise access to channel
        }
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

    func getPrinters() -> AnyPublisher<[Printer], TransportSessionError> {
        let command =
            // Single source of truth for SunOS release 4 (still used by sunfire)
            #"cat /etc/printcap "# +
        // Remove all instances of backslashes followed by newline
        #"| perl -pe 's/\\\n//' "# +
        // Remove all comments
        #"| gsed -re 's/#.*//g' "# +
        // Remove all configuration contents (begins with colon)
        #"| gsed -re 's/:[a-z].*$//' "# +
        // Remove the colon that comes after the printer names
        #"| gsed -re 's/:.*$//' "# +
        // Remove all empty lines
        #"| gawk NF"#

        return execute(command: command, requestPty: false)
            .map { output in
                output.split(separator: "\n").map { Printer(name: String($0)) }
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
