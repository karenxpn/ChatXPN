//
//  ChatList.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI

struct ChatList: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @State private var searchText = ""
    let callApiKey: String
    
    var body: some View {
        List {
            ForEach(searchResults, id: \.id) { chat in
                ChatListCell(chat: chat, callApiKey: callApiKey)
                    .listRowInsets(EdgeInsets())

            }
            
            if chatVM.loading && !chatVM.chats.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            Spacer()
                .padding(.bottom, UIScreen.main.bounds.height * 0.15)
                .listRowSeparator(.hidden)
        }.refreshable {
            chatVM.getChats()
        }.listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
    }
    
    var searchResults: [ChatModelViewModel] {
        if searchText.isEmpty {
            return chatVM.chats
        } else {
            return chatVM.chats.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    ChatList(callApiKey: "")
        .environmentObject(ChatViewModel())
}
