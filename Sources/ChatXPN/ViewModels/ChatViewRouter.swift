//
//  ChatViewRouter.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import SwiftUI
import NotraAuth

class ChatViewRouter: AlertViewModel, ObservableObject {
    @Published var chatPath = [ChatPath]()

    // add new view
    func pushChatPath(_ page: ChatPath)        { chatPath.append(page) }
    
    // pop one view
    func popChatPath()      { chatPath.removeLast() }
    
    // pop root view
    func popToChatRoot()        { chatPath.removeLast(chatPath.count) }
    
    @ViewBuilder
    func buildChatView(page: ChatPath) -> some View {
        switch page {

        case .chat:
            Text( "Chat")
//            Chat()
        case .chatRoom(let chat):
            Text( "Chat room" )
//            ChatRoom(chat: chat)
        }
    }
}
