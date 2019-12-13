//
//  QuotaView.swift
//  printsoc
//
//  Created by Julius on 12/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import SwiftUI

struct QuotaView: View {
    @State var cancellables = Set<AnyCancellable>()
    @EnvironmentObject var state: AppState

    var usage: PaperUsage? {
        state.data?.usage
    }

    var greeting: String {
        guard let name = state.data?.fullName else {
            return "Hi!"
        }
        return "Hi \(name)!"
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(greeting).padding()
                PrintUsageView(usage: self.usage)
            }
            .navigationBarItems(trailing:
                HStack(alignment: .center) {
                    Button(action: self.refresh, label: {
                        Image(uiImage: UIImage(systemName: "arrow.clockwise")!)
                    })
                    Divider()
                    Button(action: self.logout, label: {
                        Text("Log Out")
                    })
            })
            .navigationBarTitle(Text("Quota"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem { TabLabel(imageSystemName: "cart.fill", text: "Quota") }
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

struct QuotaView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            QuotaView().environmentObject(AppState())
        }
    }
}
