//
//  ChatRoom.swift
//
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI
import FirebaseFirestore
import NotraAuth
import FirebaseAuth
import CameraXPN

struct ChatRoom: View {
    let chat: ChatModelViewModel
    @StateObject private var roomVM = RoomViewModel()
    @Environment(\.apiKey) var apiKey
    
    var body: some View {
        ZStack {
            
            MessagesList()
            
            VStack {
                Spacer()
                MessageBar()
            }
        }.environmentObject(roomVM)
            .ignoresSafeArea(.container, edges: .bottom)
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
                
                if !roomVM.messages.contains(where: { $0.callEnded == false && $0.type == .call }) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            roomVM.getTokenAndSendVideoCallMessage(join: false) { (token, callId) in
                                if let token, let callId {
                                    roomVM.fullScreen = .call(token: token, callId: callId, users: chat.users)
                                }
                            }
                        } label: {
                            if roomVM.loadingCall { ProgressView() }
                            else {
                                Image(systemName: "video")
                                    .tint(.primary)
                            }
                        }.disabled(roomVM.loadingCall)
                    }
                }
                
            }.alert("error"~, isPresented: $roomVM.showAlert, actions: {
                Button("gotIt"~, role: .cancel) { }
            }, message: {
                Text(roomVM.alertMessage)
            }).fullScreenCover(item: $roomVM.fullScreen, content: { screen in
                switch screen {
                case .media(let url, let type):
                    SingleMediaContentPreview(url: url, mediaType: type)
                case .call(let token, let callId, let users):
                    VideoCall(token: token,
                              callId: callId,
                              apiKey: apiKey,
                              users: users.filter{ $0.id != Auth.auth().currentUser?.uid },
                              endCall: { callId in
                        roomVM.endCall(callId: callId)
                        print("call ended")
                    })
                    
                case .camera:
                    CameraXPN(action: { url, data in
                        roomVM.media = data
                        roomVM.sendMessage(messageType: .photo)
                    }, font: .custom("Inter-SemiBold", size: 14), permissionMessage: "enableAccessForBoth",
                              recordVideoButtonColor: .primary,
                              useMediaContent: "useThisMedia"~, videoAllowed: false)
                    
                }
            })
    }
}

#Preview {
    ChatRoom(chat: PreviewModels.chats[0])
}
