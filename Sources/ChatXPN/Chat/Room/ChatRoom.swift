//
//  ChatRoom.swift
//  
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI
import FirebaseFirestore
import NotraAuth

struct ChatRoom: View {
    let chat: ChatModelViewModel
    @State private var message: String = ""
    
    @StateObject private var roomVM = RoomViewModel()
    
    var body: some View {
        ZStack {
            
            MessagesList(messages: roomVM.messages)
                .environmentObject(roomVM)
            
            VStack {
                Spacer()
                MessageBar()
                    .environmentObject(roomVM)
            }
        }.ignoresSafeArea(.container, edges: .bottom)
            .onAppear {
                NotificationCenter.default.post(name: Notification.Name("hideTabBar"), object: nil)
                roomVM.chatID = chat.id
                roomVM.getMessages()
            }
            .onDisappear {
                NotificationCenter.default.post(name: Notification.Name("showTabBar"), object: nil)
            }.navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextHelper(text: chat.name,
                               fontSize: 20)
                    .kerning(0.56)
                    .accessibilityAddTraits(.isHeader)
                }
            }.alert(NSLocalizedString("error", comment: ""), isPresented: $roomVM.showAlert, actions: {
                Button(NSLocalizedString("gotIt", comment: ""), role: .cancel) { }
            }, message: {
                Text(roomVM.alertMessage)
            })
    }
}

#Preview {
    ChatRoom(chat: PreviewModels.chats[0])
}
