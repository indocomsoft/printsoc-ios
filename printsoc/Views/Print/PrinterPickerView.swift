//
//  PrinterPickerView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrinterPickerView: View {
    @EnvironmentObject var state: AppState

    @State private var query: String = ""

    private var filteredPrinters: [Printer] {
        query.isEmpty ? state.printers : state.printers.filter { $0.name.lowercased().contains(query.lowercased())
        }
    }

    var body: some View {
        Form {
            Section(footer: Text("Printer with thumbs-up has no user restriction")) {
                TextField("Filter", text: $query)
            }
            List(filteredPrinters, id: \.name) { printer in
                Button(action: { self.state.selectedPrinter = printer }, label: {
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(.blue)
                            .opacity(printer.isStudentPrinter ? 1 : 0)
                        Text(printer.name)
                        Spacer()
                        if self.state.selectedPrinter == printer {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                })
                    .foregroundColor(.primary)
            }
        }.onAppear {}
    }
}

struct PrinterPickerView_Previews: PreviewProvider {
    static let printers = ["psts", "psab-01"].map { Printer(name: $0) }
    static let appState = AppState(printers: printers,
                                   selectedPrinter: printers[1])

    static var previews: some View {
        PrinterPickerView().environmentObject(appState)
    }
}
