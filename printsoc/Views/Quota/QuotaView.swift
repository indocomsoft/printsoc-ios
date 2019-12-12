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
        VStack {
            Text(greeting).padding()
            PrintUsageView(usage: self.usage)
        }
        .tabItem { TabLabel(imageSystemName: "house.fill", text: "Home") }
    }
}

struct QuotaView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            QuotaView().environmentObject(AppState())
        }
    }
}
