//
//  PDFPreview.swift
//  printsoc
//
//  Created by Julius on 13/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation
import PDFKit
import SwiftUI
import UIKit

struct PDFPreview: UIViewRepresentable {
    var document: PDFDocument

    func makeUIView(context _: UIViewRepresentableContext<PDFPreview>) -> PDFView {
        PDFView()
    }

    func updateUIView(_ pdfView: PDFView, context _: UIViewRepresentableContext<PDFPreview>) {
        pdfView.document = document
    }
}
