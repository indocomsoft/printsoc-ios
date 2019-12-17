//
//  PrinterPickerView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrinterPickerView: View {
    @State private var query: String = ""

    @ObservedObject var printer: Printer = .shared

    private var filteredPrinters: [Printer.Data] {
        query.isEmpty ? printer.printers : printer.printers.filter { $0.name.lowercased().contains(query.lowercased())
        }
    }

    var body: some View {
        Form {
            Section(footer: Text("Printer with thumbs-up has no user restriction")) {
                TextField("Filter", text: $query)
            }
            List(filteredPrinters, id: \.name) { printer in
                Button(action: { self.printer.selectedPrinter = printer }, label: {
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(.blue)
                            .opacity(printer.isStudentPrinter ? 1 : 0)
                        Text(printer.name)
                        Spacer()
                        if self.printer.selectedPrinter == printer {
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
    static var previews: some View {
        PrinterPickerView()
    }
}
