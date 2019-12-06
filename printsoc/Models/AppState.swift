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

    func storeAccount(username: String, password: String,
                      onCompletion: @escaping (Result<Account, TransportError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            let session = NMSSHSession.connect(toHost: Constants.host, withUsername: username)
            guard session.isConnected else {
                DispatchQueue.main.async { onCompletion(.failure(.noConnection)) }
                return
            }
            session.authenticate(byPassword: password)
            guard session.isAuthorized else {
                DispatchQueue.main.async { onCompletion(.failure(.unauthorized)) }
                return
            }
            let account = Account(username: username, password: password)
            do {
                try account.createInSecureStore()
            } catch {
                fatalError("Unable to save credentials to keychain")
            }
            UserDefaults.standard.set(account.username, forKey: Constants.userDefaultsKey)
            DispatchQueue.main.async { [weak self] in
                self?.loggedIn = true
                onCompletion(.success(account))
            }
        }
    }
}
