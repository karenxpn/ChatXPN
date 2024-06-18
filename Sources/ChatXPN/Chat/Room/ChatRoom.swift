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
    @State private var message: String = ""
    @StateObject private var roomVM = RoomViewModel()
    
    @Environment(\.apiKey) var apiKey

    
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
                print("the api key for the call is \(apiKey)")
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
                }
            }.alert("error"~, isPresented: $roomVM.showAlert, actions: {
                Button("gotIt"~, role: .cancel) { }
            }, message: {
                Text(roomVM.alertMessage)
            }).fullScreenCover(item: $roomVM.fullScreen, content: { screen in
                switch screen {
                case .media(let url, let type):
                    SingleMediaContentPreview(url: url, mediaType: type)
                case .call(let token, let callId, let users, let create):
                    Text( "Full Screen of call" )
                case .camera:
                    CameraXPN(action: { url, data in
                        roomVM.media = data
                        roomVM.sendMessage(messageType: .photo)
                    }, font: .custom("Inter-SemiBold", size: 14), permissionMessage: "enableAccessForBoth",
                              recordVideoButtonColor: .primary,
                              useMediaContent: "useThisMedia"~, videoAllowed: false)

                }
            })
//            .fullScreenCover(item: $roomVM.token, onDismiss: {
//                roomVM.endCall()
//            }, content: { token in
//                VideoCall(token: token,
//                          callId: roomVM.callId ?? "",
//                          apiKey: callApiKey,
//                          users: chat.users.filter{ $0.id != Auth.auth().currentUser?.uid },
//                          create: !roomVM.joiningCall)
//            })
    }
}

#Preview {
    ChatRoom(chat: PreviewModels.chats[0])
}
