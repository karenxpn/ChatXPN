//
//  MessagesList.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 07.05.24.
//

import SwiftUI

struct MessagesList: View {
    @EnvironmentObject var roomVM: RoomViewModel
    let messages: [MessageViewModel]
        
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { scrollView in
                
                LazyVStack(spacing: 0) {
                    
                    ForEach(messages, id: \.id) { message in
                        MessageCell(message: message)
                            .environmentObject(roomVM)
                            .padding(.bottom, messages[0].id == message.id ? UIScreen.main.bounds.size.height * 0.1 : 0)
                            .padding(.bottom, messages[0].id == message.id && roomVM.replyMessage != nil ? UIScreen.main.bounds.height * 0.1 : 0)
                            .rotationEffect(.radians(3.14))
                            .task {
                                if message.id == messages.last?.id && !roomVM.loading && roomVM.lastMessage != nil {
                                    roomVM.getMessages()
                                }
                                
                                if message.received && !message.seen && !messages.contains(where: { $0.callEnded == false }) {
                                    roomVM.markMessageRead(messageID: message.id)
                                }
                            }
                    }
                    
                    if roomVM.loading {
                        ProgressView()
                            .padding()
                            .padding(.top, roomVM.messages.isEmpty ? UIScreen.main.bounds.height * 0.11 : 0)
                    }
                }.padding(.top, 20)
            }
        }.rotationEffect(.radians(3.14))
            .scrollDismissesKeyboard(.immediately)
        .padding(.top, 1)
    }
}


#Preview {
    MessagesList(messages: [PreviewModels.message, PreviewModels.emojiMessage, PreviewModels.photoMessage])
        .environmentObject(RoomViewModel())
}
