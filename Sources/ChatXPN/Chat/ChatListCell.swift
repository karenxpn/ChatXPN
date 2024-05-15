//
//  ChatListCell.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI
import NotraAuth

struct ChatListCell: View {
    @EnvironmentObject var viewRouter: ChatViewRouter
    let chat: ChatModelViewModel
    
    var body: some View {
        Button {
            viewRouter.pushChatPath(.chatRoom(chat: chat))
        } label: {
            HStack(alignment: .top, spacing: 14) {
                
                ImageHelper(image: chat.image , contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    TextHelper(text: chat.name, fontSize: 18)
                        .lineLimit(1)
                    
                    TextHelper(text: chat.content, fontSize: 14)
                        .lineLimit(1)
                }
                
                Spacer()
                                
                VStack(alignment: .trailing, spacing: 10) {
                    TextHelper(text: "\(chat.date)", color: .gray, fontSize: 11)
                        .lineLimit(1)
                    
                    if !chat.isMessageReceived {
                        Image(chat.seen ? "read_icon" : "sent_icon", bundle: .module)
                            .renderingMode(.template)
                            .colorMultiply(chat.seen ? Color("turquoise", bundle: .module) : Color("messageTime", bundle: .module))
                    }
                }
            }.padding(.horizontal, 20)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .background(
                    (chat.seen || !chat.isMessageReceived) ? .clear : Color("turquoise", bundle: .module).opacity(0.3)
                )
        }.buttonStyle(.plain)
    }
}

#Preview {
    ChatListCell(chat: PreviewModels.chats[0])
        .environmentObject(ChatViewRouter())
}
