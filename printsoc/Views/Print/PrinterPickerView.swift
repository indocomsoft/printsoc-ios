//
//  PrinterPickerView.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import SwiftUI

private class _PrinterPickerViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var filteredPrinters: [Printer.Data]

    private var cancellable: AnyCancellable?

    init(printer: Printer = .shared, initialPrinters: [Printer.Data] = []) {
        filteredPrinters = initialPrinters

        cancellable = $query
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else {
                    return
                }
                if query.isEmpty {
                    self.filteredPrinters = printer.printers
                } else {
                    self.filteredPrinters = printer.printers
                        .filter { $0.name.lowercased().contains(query.lowercased()) }
                }
            }
    }
}

private struct _PrinterPickerView: View {
    @ObservedObject var printer: Printer = .shared

    @ObservedObject var viewModel: _PrinterPickerViewModel

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        Form {
            Section(footer: Text("Printer with thumbs-up has no user restriction")) {
                TextField("Filter", text: $viewModel.query)
            }
            List(viewModel.filteredPrinters, id: \.name) { printer in
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
        }
        .navigationBarTitle(Text("Choose Printers"))
        .navigationBarItems(trailing: HStack {
            Button(action: self.refresh) {
                Image(uiImage: UIImage(systemName: "arrow.clockwise")!)
            }
        })
    }

    private func refresh() {
        printer.update()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

struct PrinterPickerView: View {
    // Because we cannot apply @State together with @ObservedObject,
    // so we need some kind of a "container view" whose task is
    // just to maintain reference to the viewModel
    @State private var viewModel: _PrinterPickerViewModel = _PrinterPickerViewModel()

    var body: some View {
        _PrinterPickerView(viewModel: viewModel)
    }
}

struct PrinterPickerView_Previews: PreviewProvider {
    static let printers = [Printer.Data(name: "psts"), Printer.Data(name: "abcde")]

    static var previews: some View {
        NavigationView {
            _PrinterPickerView(viewModel: _PrinterPickerViewModel(printer: Printer(printers: printers),
                                                                  initialPrinters: printers))
        }
    }
}
