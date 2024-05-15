//
//  MessageContent.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI

struct MessageContent: View {
    let message: MessageViewModel
    
    var body: some View {
        
        ZStack( alignment: .bottomTrailing) {
            
            if message.type == .text {
                TextMessageContent(message: message)
            } else if message.type == .photo {
                PhotoMessageContent(message: message)
            } else if message.type == .file {
                FileMessageContent(message: message)
            }
            
            HStack {
                ForEach(Array(Set(message.reactionModels.map{ $0.reaction })), id: \.self) { reaction in
                    Text( "\(reaction) \(message.reactionModels.filter{ $0.reaction == reaction }.count)" )
                        .font(.custom("Inter-Regular", size: 10))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color("messageMenu", bundle: .module))
                        .cornerRadius(20)
                        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
                }
            }.offset(x: -10,y: 10)
        }
    }
}

#Preview("Text Message") {
    MessageContent(message: PreviewModels.message)
}

#Preview("Photo Message") {
    MessageContent(message: PreviewModels.photoMessage)
}

#Preview("Emoji Message") {
    MessageContent(message: PreviewModels.emojiMessage)
}
