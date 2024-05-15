//
//  SingleMediaContentPreview.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI
import AVFoundation

struct SingleMediaContentPreview: View {
    @Environment(\.presentationMode) var presentationMode
    let url: URL
    let mediaType: MessageType
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("close_popup", bundle: .module)
                        .scaleEffect(0.8)
                        .padding()
                }

            }
            
            Spacer()
            
            if mediaType == .photo {
                ImageHelper(image: url.absoluteString, contentMode: .fit)
            } else if mediaType == .file {
                PDFKitContainerView(url: url)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SingleMediaContentPreview(url: URL(string: "https://s3-alpha-sig.figma.com/img/c252/0419/27718eefce1789c59499f91fec79c8b2?Expires=1715558400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Ck-kLFxqTqKNE~c5z06Igcy0tEc-iDO9IEngHEic~wDEe67QZee9Jpu4vn0qmVbVGWQXvTrQbgcLmtLj8u5JDDorY67sDBV5VbxBLCXXa6DP2sNU1k4UH2FAAay8Hf-wXoS~YLJ73qtocXk3cvYgyt8NFhVPWtxzlfGWLdqGAXdLsjOGps3NwEKzpXIhHS~XbtoDWfBQ21uVjPgE3VOELn8CeYT~4A79fl3ZYNNLOJXvVhrcPAIjI8tJ~y6~kSCGy-JUKjSWgLTnYUFDP8K2nrlB649NnYsbaqrJ42bdrMqXxWjYJYjZCo-oVa8AglKXdQYX1EyExjc3Mmjoz4HF0w__")!, mediaType: .photo)
}
