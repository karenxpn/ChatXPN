//
//  ReplyedToMessagePreview.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 10.05.24.
//

import SwiftUI
import NotraAuth
import DataCache

struct ReplyedToMessagePreview: View {
    let sent: Bool
    let repliedTo: RepliedMessageModel
    let contentType: MessageType
        
    var body: some View {
        HStack( alignment: .center) {
            Capsule()
                .fill(sent ? .white : Color("turquoise", bundle: .module))
                .frame(width: 3, height: 30)
            
            LazyVStack( alignment: .leading, spacing: 5) {
                
                TextHelper(text: repliedTo.name, color: sent ? .white : Color("turquoise", bundle: .module))
                
                if repliedTo.type == .text {
                    TextHelper(text: repliedTo.message, color: sent ? .white : .black)
                        .lineLimit(1)
                    
                } else if repliedTo.type == .photo {
                    ImageHelper(image: repliedTo.message, contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if repliedTo.type == .file {
                    if let thumbnail = DataCache.instance.readImage(forKey: repliedTo.message + "thumbnail") {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                    }
                }
            }
        }
    }
}

#Preview {
    ReplyedToMessagePreview(sent: true, repliedTo: RepliedMessageModel(message: "Helloooo", type: .text, name: "Karen"), contentType: .text)
}
