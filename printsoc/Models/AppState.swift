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

    private func storeUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: key)
        loggedIn = true
    }

    func storeAccount(_ account: Account) {
        do {
            try account.createInSecureStore()
        } catch {
            fatalError("Unable to save credentials to keychain")
        }
        storeUsername(account.username)
    }

    func getAccount() -> Account? {
        guard let username = getUsername(),
            let result = Account(username: username, password: "").readFromSecureStore(),
            let password = result.data?[Account.dataKey] as? String else {
            return nil
        }
        return Account(username: username, password: password)
    }
}
