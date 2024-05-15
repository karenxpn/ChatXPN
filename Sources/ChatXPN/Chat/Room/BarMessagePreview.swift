//
//  BarMessagePreview.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI
import NotraAuth
import DataCache

struct BarMessagePreview: View {
    @Binding var message: MessageViewModel?

    var body: some View {
        
        HStack( alignment: .top) {
            Capsule()
                .fill(Color("turquoise", bundle: .module))
                .frame(width: 3, height: 35)
            
            if let message = message {
                VStack( alignment: .leading) {
                    
                    TextHelper(text: message.senderName, color: Color("turquoise", bundle: .module))
                    
                    if message.type == .text {
                        TextHelper(text: message.content)
                            .lineLimit(1)
                        
                    } else if message.type == .photo {
                        ImageHelper(image: message.content, contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if message.type == .file {
                        if let thumbnail = DataCache.instance.readImage(forKey: message.content + "thumbnail") {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    message = nil
                }
            } label: {
                Image("close_reply")
            }
        }.padding(.horizontal, 20)
            .padding(.top, 15)
            .background(Color("messageBar", bundle: .module))
            .cornerRadius(35, corners: [.topLeft, .topRight])
            .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: -3)
    }
}

#Preview {
    BarMessagePreview(message: .constant(PreviewModels.message))
}
