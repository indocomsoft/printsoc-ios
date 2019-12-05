//
//  State.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation

final class AppState: ObservableObject {
    private let key = "username"

    @Published var loggedIn: Bool = false

    init() {
        loggedIn = getAccount() != nil
    }

    private func getUsername() -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    func storeAccount(_ account: Account) {
        do {
            try account.createInSecureStore()
        } catch {
            fatalError("Unable to save credentials to keychain")
        }
        UserDefaults.standard.set(account.username, forKey: key)
        loggedIn = true
    }

    func getAccount() -> Account? {
        guard let username = getUsername(),
            let result = Account(username: username, password: "").readFromSecureStore(),
            let password = result.data?[Account.dataKey] as? String else {
            return nil
        }
        return Account(username: username, password: password)
    }

    func deleteAccount() {
        guard let username = getUsername() else {
            return
        }
        UserDefaults.standard.removeObject(forKey: key)
        do {
            try Account(username: username, password: "").deleteFromSecureStore()
        } catch {
            fatalError("Unable to delete credentials from keychain")
        }
        loggedIn = false
    }
}
