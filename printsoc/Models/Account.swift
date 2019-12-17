//
//  Account.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation
import Locksmith

private struct _Account: CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable,
    GenericPasswordSecureStorable {
    static let dataKey = "password"

    let username: String
    let password: String

    let service = "sunfire"
    var account: String { username }

    var data: [String: Any] {
        [_Account.dataKey: password]
    }

    static func password(for username: String) -> String? {
        _Account(username: username, password: "").readFromSecureStore()?.data?[dataKey] as? String
    }

    static func save(username: String, password: String) throws {
        try _Account(username: username, password: password).createInSecureStore()
    }

    static func delete(username: String) throws {
        try _Account(username: username, password: "").deleteFromSecureStore()
    }
}

final class Account: ObservableObject {
    static let shared = Account()

    @Published var isLoggedIn: Bool = false
    @Published var fullName: String?

    private let userDefaultsKey = "username"

    private var cancellables = Set<AnyCancellable>()

    private var savedUsername: String? {
        UserDefaults.standard.string(forKey: userDefaultsKey)
    }

    private var savedPassword: String? {
        guard let username = savedUsername else {
            return nil
        }
        return _Account.password(for: username)
    }

    var transportSession: AnyPublisher<DefaultTransport.Session, PrintsocError> {
        guard let username = savedUsername, let password = savedPassword else {
            return Fail(error: TransportError.unauthorized)
                .mapError { PrintsocError.transportError($0) }
                .eraseToAnyPublisher()
        }
        return DefaultTransport.authenticate(username: username, password: password)
            .mapError { PrintsocError.transportError($0) }
            .eraseToAnyPublisher()
    }

    init() {
        isLoggedIn = savedUsername != nil

        update()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func update() -> AnyPublisher<Void, PrintsocError> {
        Just(savedUsername)
            .setFailureType(to: PrintsocError.self)
            .flatMap { [weak self] maybeUsername -> AnyPublisher<String, PrintsocError> in
                guard let self = self else {
                    return Fail(error: PrintsocError.strongReference)
                        .eraseToAnyPublisher()
                }
                guard let username = maybeUsername else {
                    return Just(())
                        .setFailureType(to: PrintsocError.self)
                        .receive(on: DispatchQueue.main)
                        .flatMap { () -> AnyPublisher<String, PrintsocError> in
                            self.isLoggedIn = false
                            return Fail(error: PrintsocError.transportError(.unauthorized))
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                return self.transportSession
                    .flatMap { session in
                        session.getFullName(for: username)
                            .mapError { PrintsocError.transportSessionError($0) }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] fullName in
                self?.isLoggedIn = true
                self?.fullName = fullName
            }
            .eraseToAnyPublisher()
    }

    func delete() -> AnyPublisher<Void, PrintsocError> {
        Deferred {
            Future<Void, PrintsocError> { [weak self] promise in
                guard let self = self,
                    let username = self.savedUsername
                else {
                    return promise(.failure(PrintsocError.strongReference))
                }
                do {
                    try _Account.delete(username: username)
                } catch {
                    return promise(.failure(PrintsocError.keychainError))
                }
                UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
                return promise(.success(()))
            }
        }
        .flatMap { [weak self] _ -> AnyPublisher<Void, PrintsocError> in
            guard let self = self else {
                return Fail(error: PrintsocError.strongReference)
                    .eraseToAnyPublisher()
            }
            return self.update().eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func store(username: String, password: String) -> AnyPublisher<Void, PrintsocError> {
        DefaultTransport
            .authenticate(username: username, password: password)
            .mapError { PrintsocError.transportError($0) }
            .flatMap { [weak self] _ -> AnyPublisher<Void, PrintsocError> in
                guard let self = self else {
                    return Fail(error: PrintsocError.strongReference)
                        .eraseToAnyPublisher()
                }
                do {
                    try _Account.save(username: username, password: password)
                } catch {
                    switch error {
                    case LocksmithError.duplicate:
                        return self.delete()
                    default:
                        return Fail(error: PrintsocError.keychainError)
                            .eraseToAnyPublisher()
                    }
                }
                UserDefaults.standard.set(username, forKey: self.userDefaultsKey)
                return self.update().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
