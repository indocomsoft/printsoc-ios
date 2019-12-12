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
    @State var cancellables = Set<AnyCancellable>()

    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationView {
            TabView {
                QuotaView().environmentObject(state)
            }
            .navigationBarItems(trailing:
                HStack(alignment: VerticalAlignment.center) {
                    Button(action: self.refresh, label: {
                        Image(uiImage: UIImage(systemName: "arrow.clockwise")!)
                    })
                    Divider()
                    Button(action: self.logout, label: {
                        Text("Log Out")
                    })
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func refresh() {
        state.update()
            .sink(receiveCompletion: { _ in },
                  receiveValue: {})
            .store(in: &cancellables)
    }

    private func logout() {
        state.deleteAccount()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState())
    }
}
