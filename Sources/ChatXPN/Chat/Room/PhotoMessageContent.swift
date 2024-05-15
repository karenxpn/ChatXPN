//
//  PhotoMessageContent.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI

struct PhotoMessageContent: View {
    let message: MessageViewModel
    
    var body: some View {
        
        VStack( alignment: !message.received ? .trailing : .leading) {

            HStack(alignment: .bottom, spacing: 8) {
                if message.content.hasPrefix("https://") {
                    ImageHelper(image: message.content, contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    // view here
                } else {
                    if message.status == .pending && !message.received {
                        
                        if let data = Data(base64Encoded: message.content), let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.4)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    ProgressView()
                                }
                        }
                    }
                }
                
                if !message.received && message.status != .pending {
                    Image(message.seen ? "read_icon" : "sent_icon", bundle: .module)
                        .renderingMode(.template)
                        .tint(Color("messageTime", bundle: .module))
                        .scaleEffect(1.2)
                }
            }
        }.padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background( Color(!message.received ? "turquoise" : "tabShadow", bundle: .module))
            .cornerRadius(20, corners: !message.received ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
    }
}

#Preview {
    PhotoMessageContent(message: PreviewModels.photoMessage)
}
