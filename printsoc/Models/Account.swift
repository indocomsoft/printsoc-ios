//
//  Account.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation
import Locksmith

struct Account: CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable,
    GenericPasswordSecureStorable {
    let username: String
    let password: String

    let service = "sunfire"
    var account: String { username }

    var data: [String: Any] {
        [Constants.keychainDataKey: password]
    }
}