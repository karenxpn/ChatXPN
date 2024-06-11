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
    
    var body: some View {
        
        VStack( alignment: !message.received ? .trailing : .leading) {

            HStack(alignment: .bottom, spacing: 8) {
                
                Image(systemName: "video")
                TextHelper(text: message.content, color: !message.received ? .white : .primary)
                
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
    CallMessageContent(message: PreviewModels.callMessage)
}
