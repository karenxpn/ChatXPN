//
//  ImageHelper.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import SwiftUI
import SDWebImageSwiftUI
import DataCache

struct ImageHelper: View {
    let image: String
    let contentMode: ContentMode
    
    var body: some View {
        
        if let uiimage = DataCache.instance.readImage(forKey: image) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            WebImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } placeholder: {
                Image(systemName: "doc.text")
                    .tint(.primary)
            }
        }
    }
}

#Preview {
    ImageHelper(image: "", contentMode: .fit)
}
