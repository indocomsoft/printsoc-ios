//
//  PrintSettingsView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintSettingsView: View {
    @ObservedObject var printer: Printer = .shared

    @Binding var showThisView: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: PrinterPickerView()) {
                        Text("Printer")
                        Spacer()
                        Text(printer.selectedPrinter?.name ?? "Unspecified")
                    }
                }

                Button(action: self.print) {
                    Text("Print Document")
                }
            }
            .navigationBarTitle(Text("Print Settings"), displayMode: .inline)
            .navigationBarItems(trailing: HStack {
                Button(action: { self.showThisView = false }) {
                    Text("Close")
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func print() {
        // TODO: implement
    }
}

struct PrintSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PrintSettingsView(showThisView: .constant(true))
    }
}
