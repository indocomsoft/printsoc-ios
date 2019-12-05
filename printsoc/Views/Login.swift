//
//  Login.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import NMSSH
import SwiftUI

struct Login: View {
    @EnvironmentObject var state: AppState

    @State private var username = ""
    @State private var password = ""

    @State private var reason = ""
    @State private var showErrorAlert = false

    var body: some View {
        Form {
            TextField("SoC username", text: $username)
                .padding()
            SecureField("Password", text: $password)
                .padding()
            Button("Log in") {
                self.login()
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(reason),
                      dismissButton: .default(Text("Ok")) {
                          self.showErrorAlert = false
                })
            }
            .padding()
        }
        .navigationBarTitle("Login to sunfire")
    }

    func login() {
        let session = NMSSHSession
            .connect(toHost: "sunfire.comp.nus.edu.sg", withUsername: username)
        guard session.isConnected else {
            reason = "Unable to connect to sunfire"
            showErrorAlert = true
            return
        }
        session.authenticate(byPassword: password)
        guard session.isAuthorized else {
            reason = "Unauthorized"
            showErrorAlert = true
            return
        }
        let account = Account(username: username, password: password)
        state.storeAccount(account)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
