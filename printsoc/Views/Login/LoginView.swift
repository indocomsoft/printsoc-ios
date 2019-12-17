//
//  Login.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import SwiftUI

struct LoginView: View {
    @State private var cancellables = Set<AnyCancellable>()

    @ObservedObject private var account: Account = .shared

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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func login() {
        isLoading = true
        account.store(username: username, password: password)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    self.showErrorAlert = true
                    self.reason = error.message
                case .finished:
                    break
                }
                self.isLoading = false
            }, receiveValue: {
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
