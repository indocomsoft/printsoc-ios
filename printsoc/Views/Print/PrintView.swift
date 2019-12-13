//
//  PrintView.swift
//  printsoc
//
//  Created by Julius on 13/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import MobileCoreServices
import PDFKit
import SwiftUI

struct PrintView: View {
    @State var cancellables = Set<AnyCancellable>()
    @EnvironmentObject var state: AppState

    @State var documentURLs = [URL]()
    @State var showPicker = false
    @State var showErrorAlert = false

    private var pdfDocument: PDFDocument? {
        documentURLs.first.flatMap { url in
            _ = url.startAccessingSecurityScopedResource()
            let doc = PDFDocument(url: url)
            DispatchQueue.main.async {
                if doc == nil {
                    self.showErrorAlert = true
                    self.documentURLs = []
                }
            }
            url.stopAccessingSecurityScopedResource()
            return doc
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if pdfDocument == nil {
                    Text("No PDF opened")
                } else {
                    pdfDocument.map { PDFPreview(document: $0) }
                }
            }
            .navigationBarItems(leading: HStack(alignment: .center) {
                Button(action: { self.showPicker = true }, label: { Text("Open PDF") })
                    .sheet(isPresented: $showPicker) {
                        DocumentPicker(documentTypes: [kUTTypePDF as String], mode: .open,
                                       urls: self.$documentURLs)
                    }
                    .alert(isPresented: $showErrorAlert) {
                        Alert(title: Text("Error"), message: Text("Unable to load PDF"))
                    }

                if pdfDocument != nil {
                    Divider()
                    Button(action: {}, label: { Text("Print") })
                }
            }, trailing:
            HStack(alignment: .center) {
                Button(action: self.logout, label: {
                    Text("Log Out")
                })
            })
            .navigationBarTitle(Text(documentURLs.first.map { $0.lastPathComponent } ?? "Print"),
                                displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem { TabLabel(imageSystemName: "printer.fill", text: "Print") }
    }

    private func open() {}

    private func logout() {
        state.deleteAccount()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

struct PrintView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            PrintView()
        }
    }
}
