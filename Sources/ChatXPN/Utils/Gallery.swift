//
//  Gallery.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
import SwiftUI
import PhotosUI

struct Gallery: UIViewControllerRepresentable {
    
    let action: ((UIImage) -> Void)
    
    func makeCoordinator() -> Coordinator {
        return Gallery.Coordinator( parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: Gallery
        
        init( parent: Gallery) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            if !results.isEmpty {
                
                for (index, media) in results.enumerated() {
                    
                    let itemProvider = media.itemProvider
                    self.getPhoto(from: itemProvider, resultCount: results.count, id: index)


                    DispatchQueue.main.async {
                        picker.dismiss(animated: true)
                    }
                }
                
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        private func getPhoto(from itemProvider: NSItemProvider, resultCount: Int, id: Int) {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (img, error) in
                    
                    if let error { print("error loading image \(error.localizedDescription)") }
                    
                    if let uiimage = img as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.action(uiimage)
                        }
                    }
                }
            }
        }
    }
}
