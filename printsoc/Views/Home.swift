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

    var usageView: PrintUsageView? {
        guard let usage = PaperUsage.get(from: state) else {
            return nil
        }
        return PrintUsageView(usage: usage)
    }

    var greeting: String {
        guard let name = state.getFullName() else {
            return "Hi!"
        }
        return "Hi \(name)!"
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(greeting)
                    .padding()
                if usageView == nil {
                    Text("Quota not available")
                } else {
                    usageView
                }
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
