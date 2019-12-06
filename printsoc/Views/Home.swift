//
//  Home.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack {
            Text("Logged in, username = \(state.getAccount()?.username ?? "nil")")
                .padding()
            Button("Log out") {
                self.state.deleteAccount()
            }
            .padding()
        }
        .navigationBarTitle("Home")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(AppState())
    }
}
