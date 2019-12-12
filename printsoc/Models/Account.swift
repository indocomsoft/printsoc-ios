//
//  Account.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

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
}

enum Account {
    static func save(username: String, password: String) throws {
        try _Account(username: username, password: password).createInSecureStore()
    }

    static func delete(username: String) throws {
        try _Account(username: username, password: "").deleteFromSecureStore()
    }

    static func password(for username: String) -> String? {
        _Account.password(for: username)
    }
}
