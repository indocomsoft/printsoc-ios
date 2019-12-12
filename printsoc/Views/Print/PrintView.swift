//
//  PrintView.swift
//  printsoc
//
//  Created by Julius on 13/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .tabItem { TabLabel(imageSystemName: "printer.fill", text: "Print") }
    }
}

struct PrintView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            PrintView()
        }
    }
}
