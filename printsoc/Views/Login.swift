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
    @EnvironmentObject private var state: AppState

    @State private var username = ""
    @State private var password = ""

    @State private var reason = ""
    @State private var showErrorAlert = false

    @State private var isLoading = false

    private var form: some View {
        Form {
            TextField("SoC username", text: self.$username)
            SecureField("Password", text: self.$password)
            Button(action: self.login, label: {
                Text("Log in")
            })
                .alert(isPresented: self.$showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(self.reason))
                }
        }
        .navigationBarTitle("Login to Sunfire")
    }

    var body: some View {
        NavigationView {
            if isLoading {
                form.overlay(
                    ActivityIndicator(isAnimating: $isLoading, style: .large)
                        .frame(width: 100, height: 100)
                        .background(Color.secondary)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        .opacity(0.5)
                )
            } else {
                form
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    private func login() {
        isLoading = true
        state.storeAccount(username: username, password: password) { result in
            switch result {
            case let .failure(error):
                self.showErrorAlert = true
                self.reason = error.message
            case .success: break
            }
            self.isLoading = false
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
