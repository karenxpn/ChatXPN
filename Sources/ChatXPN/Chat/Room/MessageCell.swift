//
//  MessageCell.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 06.05.24.
//

import SwiftUI
import NotraAuth
import Popovers

struct MessageCell: View {
    
    @EnvironmentObject var roomVM: RoomViewModel
    @State private var showPopOver: Bool = false
    
    let message: MessageViewModel
    let reactions = ["👍", "👎", "❤️", "😂", "🤣", "😡", "😭"]
    
    var body: some View {
        HStack( alignment: .bottom, spacing: 10) {
            
            if !message.received { Spacer() }
            
            if !message.received {
                TextHelper(text: "\(message.createdAt)", color: Color("messageTime", bundle: .module), fontSize: 8)
            }
            
            MessageContent(message: message)
                .contentShape(Rectangle())
                .scaleEffect(showPopOver ? 0.85 : 1)
                .blur(radius: showPopOver ? 0.7 : 0)
                .animation(.easeInOut, value: showPopOver)
                .delaysTouches(for: 0.2) {
                    if message.type == .photo || message.type == .file {
                        roomVM.fullScreen = .media(url: URL(string: message.content)!, type: message.type)
                    } else if message.type == .call && message.callEnded == false && !roomVM.loadingCall {
                        roomVM.getTokenAndSendVideoCallMessage(join: true, callId: message.id) { (token, callId) in
                            if let token, let callId {
                                roomVM.fullScreen = .call(token: token, callId: callId, users: [])
                            }
                        }
                    }
                }.gesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in
                            if message.status != .deleted && message.status != .pending {
                                showPopOver = true
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                        }
                ).popover(
                    present: $showPopOver,
                    attributes: {
                        $0.position = .absolute(
                            originAnchor: .top,
                            popoverAnchor: !message.received ? .bottomRight : .bottomLeft
                        )
                    }
                ) {
                    HStack {
                        
                        ForEach(reactions, id: \.self) { reaction in
                            Button {
                                roomVM.sendReaction(message: message, reaction: reaction)
                                showPopOver = false
                            } label: {
                                Text(reaction).font(.system(size: 28))
                            }
                        }
                        
                    }.padding(.horizontal, 24)
                        .padding(.vertical, 9)
                        .background(Color("messageMenu", bundle: .module))
                        .cornerRadius(20)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .popover(
                    present: $showPopOver,
                    attributes: {
                        $0.position = .absolute(
                            originAnchor: .bottom,
                            popoverAnchor: .top
                        )
                    }
                ) {
                    VStack(alignment: .leading, spacing: 0) {
                        if message.type != .call {
                            MenuButtonsHelper(label: "reply"~, icon: "arrowshape.turn.up.left", role: .cancel) {
                                roomVM.replyMessage = message
                                showPopOver = false
                            }
                        }
                        Divider()
                        
                        if message.type == .text {
                            MenuButtonsHelper(label: "copy"~, icon: "doc.on.doc", role: .cancel) {
                                UIPasteboard.general.string = message.content
                                showPopOver = false
                            }
                            Divider()
                        }
                        
                        if !message.received {
                            MenuButtonsHelper(label: "delete"~, icon: "trash", role: .destructive) {
                                roomVM.deleteMessage(messageID: message.id)
                                showPopOver = false
                            }
                        }
                        
                    }.frame(width: 170)
                        .background(Color("messageMenu", bundle: .module))
                        .cornerRadius(16)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 5)
                        .padding(.top, 5)
                }
            
            if message.received {
                TextHelper(text: "\(message.createdAt)", color: Color("messageTime", bundle: .module), fontSize: 8)
            }
            
            if message.received { Spacer() }
            
        }.padding(.horizontal, 20)
            .padding(!message.received ? .leading : .trailing, UIScreen.main.bounds.width * 0.05)
            .padding(.vertical, 8)
            .padding(.bottom, (roomVM.messages[0].id == message.id && showPopOver) ? UIScreen.main.bounds.height * 0.08 : 0)
    }
}

#Preview {
    MessageCell(message: PreviewModels.message)
        .environmentObject(RoomViewModel())
}
