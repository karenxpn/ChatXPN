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
                        roomVM.getTokenAndSendVideoCallMessage(join: false) { (token, callId) in
                            if let token, let callId {
                                roomVM.token = token
                                roomVM.callId = callId
                                roomVM.joiningCall = false
                            }
                        }
                    } label: {
                        if roomVM.loadingCall { ProgressView() }
                        else {
                            Image(systemName: "video")
                                .tint(.primary)
                        }
                    }.disabled(roomVM.loadingCall)
                        .fullScreenCover(item: $roomVM.token, onDismiss: {
                            roomVM.endCall()
                        }, content: { token in
                            VideoCall(token: token,
                                      callId: roomVM.callId ?? "",
                                      apiKey: callApiKey,
                                      users: chat.users,
                                      create: !roomVM.joiningCall)
                        })
                }
            }.alert("error"~, isPresented: $roomVM.showAlert, actions: {
                Button("gotIt"~, role: .cancel) { }
            }, message: {
                Text(roomVM.alertMessage)
            })
    }
}

#Preview {
    ChatRoom(chat: PreviewModels.chats[0], callApiKey: "")
}
