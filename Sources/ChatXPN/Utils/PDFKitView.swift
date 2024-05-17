//
//  PDFKitView.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import SwiftUI
import PDFKit
import DataCache

struct PDFKitView: UIViewRepresentable {
    
    let url: URL
    @Binding var isLoading: Bool // Changed to a binding
    @Binding var pdf: PDFDocument?

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if isLoading {
            DispatchQueue.global(qos: .background).async {
                if let pdfData = DataCache.instance.readData(forKey: url.absoluteString) {
                    if let document = PDFDocument(data: pdfData) {
                        DispatchQueue.main.async {
                            pdfView.document = document
                            pdfView.autoScales = true
                            self.isLoading = false // Set isLoading to false when loading completes
                            self.pdf = document
                        }
                    } else {
                        // Handle failure to load PDF document
                        DispatchQueue.main.async {
                            self.isLoading = false // Set isLoading to false even on failure
                        }
                    }
                } else {
                    
                    if let document = PDFDocument(url: self.url) {
                        DispatchQueue.main.async {
                            pdfView.document = document
                            pdfView.autoScales = true
                            self.isLoading = false // Set isLoading to false when loading completes
                            self.pdf = document
                            if let pdfData = document.dataRepresentation() {
                                DataCache.instance.write(data: pdfData, forKey: url.absoluteString)
                            }
                        }
                    } else {
                        // Handle failure to load PDF document
                        DispatchQueue.main.async {
                            self.isLoading = false // Set isLoading to false even on failure
                        }
                    }
                }
            }
        }
    }
    
    // Binding to expose isLoading state
    func isLoadingBinding() -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.isLoading },
            set: { newValue in self.isLoading = newValue }
        )
    }
}

struct PDFKitContainerView: View {
    let url: URL
    @State private var isLoading = true // State to control loading
    @State private var pdf: PDFDocument?

    
    var body: some View {
        ZStack {
            PDFKitView(url: url, isLoading: $isLoading, pdf: $pdf) // Pass isLoading as a binding
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.3, anchor: .center)
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let pdf {
                    ShareLink(item: pdf, preview: SharePreview(NSLocalizedString("yourPdfPreview", bundle: .module, comment: "")))
                }
            }
        }
    }
}
