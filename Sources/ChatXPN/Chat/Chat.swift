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
                    TextHelper(text: "chats"~, fontSize: 20)
                        .fontWeight(.bold)
                }
            }.alert("error"~, isPresented: $chatVM.showAlert, actions: {
                Button("ok"~, role: .cancel) { }
            }, message: {
                Text(chatVM.alertMessage)
            })
    }
}

#Preview {
    Chat()
}
