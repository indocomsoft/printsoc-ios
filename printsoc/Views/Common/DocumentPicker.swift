//
//  DocumentPicker.swift
//  printsoc
//
//  Created by Julius on 13/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    let documentTypes: [String]
    let mode: UIDocumentPickerMode

    @Binding var urls: [URL]

    func makeCoordinator() -> DocumentPicker.Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>)
        -> UIDocumentPickerViewController {
        let viewController = UIDocumentPickerViewController(documentTypes: documentTypes, in: mode)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_: UIDocumentPickerViewController,
                                context _: UIViewControllerRepresentableContext<DocumentPicker>) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ documentPicker: DocumentPicker) {
            parent = documentPicker
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.urls = urls
        }
    }
}
