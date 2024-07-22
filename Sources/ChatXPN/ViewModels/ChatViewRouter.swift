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
    
    public func handleDeeplink(from url: URL) {
        guard let host = url.host else { return }

        if host == "notralaw.page.link" {
            return
        }
        
        guard url.pathComponents.count >= 2 else { return }
        
        let destination = url.pathComponents[1]

        switch DeeplinkURLs(rawValue: host) {
        case .chat:
            let queryParams = url.queryParameters
            if let chatModelJson = url.queryParameters["chatModel"],
               let chatModel = deserializeChatModel(from: chatModelJson) {
                self.pushChatPath(.chatRoom(chat: ChatModelViewModel(chat: chatModel)))
            } else {
                print("something went wrong deserializing the chat model")
                return
            }
        default:
            print("default deeplink url")
            return
        }

    }
}
