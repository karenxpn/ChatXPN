// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct ChatXPN: View {
    @EnvironmentObject private var viewRouter: ChatViewRouter
    
    let chat: ChatModelViewModel?
    
    public init(chat: ChatModelViewModel? = nil) {
        self.chat = chat
    }
    
    public var body: some View {
        if let chat {
            ChatRoom(chat: chat)
        } else {
            NavigationStack(path: $viewRouter.chatPath) {
                Chat()
                    .navigationDestination(for: ChatPath.self) { page in
                        viewRouter.buildChatView(page: page)
                    }
            }
        }
    }
}
