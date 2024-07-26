//
//  CallMessageContent.swift
//  
//
//  Created by Karen Mirakyan on 11.06.24.
//

import SwiftUI
import NotraAuth

struct CallMessageContent: View {
    let message: MessageViewModel
    @EnvironmentObject var roomVM: RoomViewModel
    
    var body: some View {
        
        VStack( alignment: !message.received ? .trailing : .leading) {

            HStack(alignment: .bottom, spacing: 8) {
                
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "video")
                        .foregroundStyle(!message.received ? .white : .primary)
                    
                    VStack {
                        TextHelper(text: message.content, color: !message.received ? .white : .primary)
                        if message.callEnded == false {
                            HStack(spacing: 8) {
                                TextHelper(text: "joinCall"~, color: .white)
                                
                                if roomVM.loadingCall {
                                    ProgressView()
                                        .tint(.gray)
                                        .scaleEffect(0.65)
                                }
                            }.padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 16).fill(.green))

                        }
                    }
                }
                
                if !message.received && message.status != .pending {
                    Image(message.seen ? "read_icon" : "sent_icon", bundle: .module)
                        .foregroundStyle(Color("messageTime", bundle: .module))
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
    CallMessageContent(message: PreviewModels.callMessage)
}
