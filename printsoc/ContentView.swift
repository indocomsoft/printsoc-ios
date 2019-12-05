//
//  ContentView.swift
//  printsoc
//
//  Created by Julius on 5/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationView {
            if state.loggedIn {
                VStack {
                    Text("Logged in, username = \(state.getAccount()?.username ?? "nil")")
                        .padding()
                    Button("Log out") {
                        self.state.deleteAccount()
                    }
                    .padding()
                }
                .navigationBarTitle("Home")
            } else {
                Login().environmentObject(state)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
