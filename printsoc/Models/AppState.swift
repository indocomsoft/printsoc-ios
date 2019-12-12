//
//  State.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation
import NMSSH

enum AppStateError: Error {
    case transportError(TransportError)
    case transportSessionError(TransportSessionError)
    case parsingError(field: String)
    case keychainError
    case strongReference

    var message: String {
        switch self {
        case let .transportError(error): return error.message
        case let .transportSessionError(error): return "Transport session error: \(error.message)"
        case let .parsingError(field): return "Unable to parse for field \(field)"
        case .keychainError: return "Unable to perform keychain operation"
        case .strongReference: return "Unable to obtain strong reference"
        }
    }
}

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var data: Data?

    private var cancellables = Set<AnyCancellable>()

    private let userDefaultsKey = "username"

    private var savedUsername: String? {
        UserDefaults.standard.string(forKey: userDefaultsKey)
    }

    private var savedPassword: String? {
        guard let username = savedUsername else {
            return nil
        }
        return Account.password(for: username)
    }

    var transportSession: AnyPublisher<DefaultTransport.Session, AppStateError> {
        guard let username = savedUsername, let password = savedPassword else {
            return Fail(error: TransportError.unauthorized)
                .mapError { .transportError($0) }
                .eraseToAnyPublisher()
        }
        return DefaultTransport.authenticate(username: username, password: password)
            .mapError { .transportError($0) }
            .eraseToAnyPublisher()
    }

    init() {
        update()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func update() -> AnyPublisher<Void, AppStateError> {
        Just(savedUsername)
            .setFailureType(to: AppStateError.self)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] maybeUsername -> AnyPublisher<String, AppStateError> in
                self?.isLoggedIn = maybeUsername != nil
                guard let username = maybeUsername else {
                    return Fail(error: AppStateError.transportError(.unauthorized))
                        .eraseToAnyPublisher()
                }
                return Just(username)
                    .setFailureType(to: AppStateError.self)
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ -> AnyPublisher<Data, AppStateError> in
                guard let self = self else {
                    return Fail(error: AppStateError.strongReference).eraseToAnyPublisher()
                }
                guard let username = self.savedUsername else {
                    return Fail(error: AppStateError.transportError(.unauthorized))
                        .eraseToAnyPublisher()
                }
                return self.transportSession
                    .flatMap { session in
                        session.getFullName(for: username)
                            .zip(session.getPaperUsage())
                            .mapError { AppStateError.transportSessionError($0) }
                            .map { name, pusage in Data(fullName: name, usage: pusage) }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] data -> AnyPublisher<Void, AppStateError> in
                guard let self = self else {
                    return Fail(error: AppStateError.strongReference)
                        .eraseToAnyPublisher()
                }
                self.data = data
                return Just(())
                    .setFailureType(to: AppStateError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func deleteAccount() -> AnyPublisher<Void, AppStateError> {
        Deferred {
            Future<Void, AppStateError> { [weak self] promise in
                guard let self = self,
                    let username = self.savedUsername
                else {
                    return promise(.failure(AppStateError.strongReference))
                }
                do {
                    try Account.delete(username: username)
                } catch {
                    return promise(.failure(AppStateError.keychainError))
                }
                UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
                return promise(.success(()))
            }
        }
        .flatMap { [weak self] _ -> AnyPublisher<Void, AppStateError> in
            guard let self = self else {
                return Fail(error: AppStateError.strongReference).eraseToAnyPublisher()
            }
            return self.update().eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func storeAccount(username: String, password: String) -> AnyPublisher<Void, AppStateError> {
        DefaultTransport
            .authenticate(username: username, password: password)
            .mapError {
                AppStateError.transportError($0)
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, AppStateError> in
                guard let self = self else {
                    return Fail(error: AppStateError.strongReference).eraseToAnyPublisher()
                }
                do {
                    try Account.save(username: username, password: password)
                } catch {
                    return Fail(error: AppStateError.keychainError).eraseToAnyPublisher()
                }
                UserDefaults.standard.set(username, forKey: self.userDefaultsKey)
                return self.update().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
