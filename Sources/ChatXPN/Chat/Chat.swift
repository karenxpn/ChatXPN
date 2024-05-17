//
//  Chat.swift
//  
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI
import NotraAuth

struct Chat: View {
    @StateObject private var chatVM = ChatViewModel()
    
    var body: some View {
        ChatList()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(chatVM)
            .task {
                chatVM.getChats()
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    TextHelper(text: NSLocalizedString("chats", bundle: .module, comment: ""), fontSize: 20)
                        .fontWeight(.bold)
                }
            }.alert(NSLocalizedString("error", bundle: .module, comment: ""), isPresented: $chatVM.showAlert, actions: {
                Button(NSLocalizedString("ok", bundle: .module, comment: ""), role: .cancel) { }
            }, message: {
                Text(chatVM.alertMessage)
            })
    }
}

#Preview {
    Chat()
}
