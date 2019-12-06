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

final class AppState: ObservableObject {
    @Published var loggedIn: Bool = false

    init() {
        loggedIn = getAccount() != nil
    }

    private func getUsername() -> String? {
        UserDefaults.standard.string(forKey: Constants.userDefaultsKey)
    }

    func getAccount() -> Account? {
        guard let username = getUsername(),
            let result = Account(username: username, password: "").readFromSecureStore(),
            let password = result.data?[Constants.keychainDataKey] as? String else {
            return nil
        }
        return Account(username: username, password: password)
    }

    func deleteAccount() {
        guard let username = getUsername() else {
            return
        }
        UserDefaults.standard.removeObject(forKey: Constants.userDefaultsKey)
        do {
            try Account(username: username, password: "").deleteFromSecureStore()
        } catch {
            fatalError("Unable to delete credentials from keychain")
        }
        loggedIn = false
    }

    /// Asynchronously try to authenticate the given credential, and store it if successful.
    /// Upon completion, it will invoke onCompletion on the main thread
    func storeAccount(username: String, password: String,
                      onCompletion: @escaping (Result<Account, TransportError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            switch self.authenticate(username: username, password: password) {
            case .success:
                let account = Account(username: username, password: password)
                UserDefaults.standard.set(account.username, forKey: Constants.userDefaultsKey)
                do {
                    try account.createInSecureStore()
                } catch {
                    fatalError("Unable to save credentials to keychain")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.loggedIn = true
                    onCompletion(.success(account))
                }
            case let .failure(error):
                DispatchQueue.main.async { onCompletion(.failure(error)) }
            }
        }
    }

    private func authenticate(username: String, password: String) -> Result<NMSSHSession,
                                                                            TransportError> {
        let session = NMSSHSession.connect(toHost: Constants.host, withUsername: username)
        guard session.isConnected else {
            return .failure(.noConnection)
        }
        session.authenticate(byPassword: password)
        guard session.isAuthorized else {
            return .failure(.unauthorized)
        }
        return .success(session)
    }

    func authenticate() -> NMSSHSession? {
        guard let account = getAccount() else {
            return nil
        }
        switch authenticate(username: account.username, password: account.password) {
        case .failure: return nil
        case let .success(session): return session
        }
    }

    func getFullName() -> String? {
        guard let session = authenticate() else {
            return nil
        }
        return session.channel
            .execute("getent passwd julius | cut -d ':' -f 5", error: nil, timeout: 5)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
