// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct ChatXPN: View {
    @EnvironmentObject private var viewRouter: ChatViewRouter
    
    let chat: ChatModelViewModel?
    let callApiKey: String
    
    public init(chat: ChatModelViewModel? = nil, callApiKey: String) {
        self.chat = chat
        self.callApiKey = callApiKey
    }
    
    public var body: some View {
        if let chat {
            ChatRoom(chat: chat, callApiKey: callApiKey)
        } else {
            NavigationStack(path: $viewRouter.chatPath) {
                Chat(callApiKey: callApiKey)
                    .navigationDestination(for: ChatPath.self) { page in
                        viewRouter.buildChatView(page: page)
                    }
            }
        }
    }
}
