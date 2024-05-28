//
//  ChatViewRouter.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import SwiftUI
import NotraAuth

public class ChatViewRouter: AlertViewModel, ObservableObject {
    @Published public var chatPath = [ChatPath]()
    @Published public var hasUnreadMessage: Bool = false
    
    var manager: ChatServiceProtocol
    public init(manager: ChatServiceProtocol = ChatService.shared) {
        self.manager = manager
    }
    
    // add new view
    public func pushChatPath(_ page: ChatPath)        { chatPath.append(page) }
    
    // pop one view
    public func popChatPath()      { chatPath.removeLast() }
    
    // pop root view
    public func popToChatRoot()        { chatPath.removeLast(chatPath.count) }
    
    @ViewBuilder
    func buildChatView(page: ChatPath) -> some View {
        switch page {
        case .chat:
            Chat()
        case .chatRoom(let chat):
            ChatRoom(chat: chat)
        }
    }
    
    @MainActor public func checkUnreadMessages() {
        manager.checkUnreadMessage { hasMessage in
            self.hasUnreadMessage = hasMessage
        }
    }
}
