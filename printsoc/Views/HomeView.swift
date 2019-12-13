//
//  Home.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView {
            QuotaView().environmentObject(state)
            PrintView().environmentObject(state)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState())
    }
}
