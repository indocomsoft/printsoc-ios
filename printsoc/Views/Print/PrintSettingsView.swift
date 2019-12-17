//
//  PrintSettingsView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintSettingsView: View {
    @EnvironmentObject var state: AppState

    @Binding var showThisView: Bool

    var body: some View {
        NavigationView {
            Form {
                NavigationLink(
                    destination: PrinterPickerView()
                ) {
                    Text("Printer")
                    Spacer()
                    Text(state.selectedPrinter?.name ?? "Unspecified")
                }
            }
            .navigationBarTitle(Text("Print Settings"), displayMode: .inline)
            .navigationBarItems(trailing: HStack {
                Button(action: { self.showThisView = false }, label: { Text("Done") })
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PrintSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PrintSettingsView(showThisView: .constant(true))
    }
}
