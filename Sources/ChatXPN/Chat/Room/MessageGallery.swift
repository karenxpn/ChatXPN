//
//  MessageGallery.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import SwiftUI
import PhotosUI

struct MessageGallery: UIViewControllerRepresentable {
    
    let handler: ((MessageType, Data) -> Void)
    
    func makeCoordinator() -> Coordinator {
        return MessageGallery.Coordinator( parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: MessageGallery
        
        init( parent: MessageGallery) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            if !results.isEmpty {
                
                for media in results {
                    
                    let itemProvider = media.itemProvider
                    
                    guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                          let _ = UTType(typeIdentifier)
                    else { continue }
                    
                    self.getPhoto(from: itemProvider, typeIdentifier: typeIdentifier)

                    DispatchQueue.main.async {
                        picker.dismiss(animated: true)
                    }
                }
                
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        private func getPhoto(from itemProvider: NSItemProvider, typeIdentifier: String) {
            
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let url = url else { return }
                
                if let data = try? Data(contentsOf: URL(fileURLWithPath: url.path)) {
                    DispatchQueue.main.async {
                        self.parent.handler(.photo, data)
                    }
                }
            }
        }
    }
}
