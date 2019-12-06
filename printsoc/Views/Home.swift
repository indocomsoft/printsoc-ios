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
        NavigationView {
            VStack {
                Text("Logged in, username = \(state.getAccount()?.username ?? "nil")")
                    .padding()
                Text("BW quota: \(PaperUsage.get(from: state)?.bwPaperQuota ?? -1)")
            }
            .navigationBarTitle("Home")
            .navigationBarItems(trailing:
                Button(action: state.deleteAccount, label: {
                    Text("Log Out")
            }))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(AppState())
    }
}
