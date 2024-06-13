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
    let callApiKey: String
    @State private var message: String = ""
    
    @StateObject private var roomVM = RoomViewModel()
    
    @State private var token: String?
    
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
                roomVM.chatID = chat.id
                roomVM.getMessages()
            }.navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextHelper(text: chat.name,
                               fontSize: 20)
                    .kerning(0.56)
                    .accessibilityAddTraits(.isHeader)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        roomVM.getToken { token in
                            if let token { self.token = token }
                        }
                    } label: {
                        Image(systemName: "video")
                            .tint(.primary)
                    }.fullScreenCover(item: $token) { token in
                        VideoCall(token: token, callId: chat.id, apiKey: callApiKey)
                    }
                }
            }.alert(NSLocalizedString("error", bundle: .module, comment: ""), isPresented: $roomVM.showAlert, actions: {
                Button(NSLocalizedString("gotIt", bundle: .module, comment: ""), role: .cancel) { }
            }, message: {
                Text(roomVM.alertMessage)
            })
    }
}

#Preview {
    ChatRoom(chat: PreviewModels.chats[0], callApiKey: "")
}
