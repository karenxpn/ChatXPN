//
//  TextMessageContent.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI
import NotraAuth

struct TextMessageContent: View {
    let message: MessageViewModel
    
    var body: some View {
        
        if message.content.isSingleEmoji {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextHelper(text: message.content, fontSize: 102)
                
                if !message.received {
                    Image(message.seen ? "read_icon" : "sent_icon", bundle: .module)
                        .renderingMode(.template)
                        .tint(Color("messageTime", bundle: .module))
                        .scaleEffect(1.2)
                }
            }
        }
//        else if message.content.hasPrefix("https://") {
//            LinkPreview(url: URL(string: message.content))
//                .backgroundColor(message.sender.id == userID ? AppColors.accentColor : AppColors.addProfileImageBG)
//                .primaryFontColor(message.sender.id == userID ? .white : .black)
//                .secondaryFontColor(.white.opacity(0.6))
//                .titleLineLimit(3)
//                .frame(width: UIScreen.main.bounds.width * 0.5, alignment: message.sender.id == userID ? .trailing : .leading)
//        }
        else {
            VStack( alignment: !message.received ? .trailing : .leading) {
                
                if message.repliedTo != nil && message.status != .deleted {
                    ReplyedToMessagePreview(sent: !message.received, repliedTo: message.repliedTo!, contentType: message.type)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 8, content: {
                    if message.status == .deleted {
                        TextHelper(text: message.content, color: Color("superLightGray", bundle: .module))
                    } else {
                        TextHelper(text: message.content, color: !message.received ? .white : .primary)
                    }
                    
                    if !message.received {
                        Image(message.seen ? "read_icon" : "sent_icon", bundle: .module)
                            .renderingMode(.template)
                            .tint(Color("messageTime", bundle: .module))
                            .scaleEffect(1.2)
                    }
                })

            }.padding(.vertical, 12)
                .padding(.horizontal, 15)
                .background( Color(!message.received ? "turquoise" : "tabShadow", bundle: .module))
                .cornerRadius(20, corners: !message.received ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
        }
    }
}

#Preview {
    TextMessageContent(message: PreviewModels.message)
}
