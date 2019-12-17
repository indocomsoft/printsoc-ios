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

    @ViewBuilder
    var body: some View {
        if state.isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
