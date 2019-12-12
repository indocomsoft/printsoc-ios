//
//  Home.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import SwiftUI

struct Home: View {
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
                Text(greeting)
                    .padding()
                PrintUsageView(usage: self.usage)
            }
            .navigationBarTitle("Home")
            .navigationBarItems(trailing:
                HStack(alignment: VerticalAlignment.center) {
                    Button(action: self.refresh, label: {
                        Image(uiImage: UIImage(systemName: "arrow.clockwise")!)
                    })
                    Divider()
                    Button(action: self.deleteAccount, label: {
                        Text("Log Out")
                    })
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
//        .onAppear {
//            self.refresh()
//        }
    }

    private func refresh() {
        state.update()
            .sink(receiveCompletion: { _ in },
                  receiveValue: {})
            .store(in: &cancellables)
    }

    func deleteAccount() {
        state.deleteAccount()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(AppState())
    }
}
