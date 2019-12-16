//
//  PrintSettingsView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintSettingsView: View {
    @State var printer: String?

    @Binding var showThisView: Bool

    var body: some View {
        NavigationView {
            Form {
                NavigationLink(destination: PrinterPickerView()) {
                    Text("Printer")
                    Spacer()
                    Text(printer ?? "Unspecified")
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
