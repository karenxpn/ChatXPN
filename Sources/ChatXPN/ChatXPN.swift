// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct ChatXPN: View {
    @EnvironmentObject private var viewRouter: ChatViewRouter
    @Environment(\.dismiss) var dismiss

    let chat: ChatModelViewModel?
    
    public init(chat: ChatModelViewModel? = nil) {
        self.chat = chat
    }
    
    public var body: some View {
        NavigationStack(path: $viewRouter.chatPath) {
            if let chat {
                ChatRoom(chat: chat)
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image("close_popup")
                            }
                        }
                    })
            } else {
                Chat()
                    .navigationDestination(for: ChatPath.self) { page in
                        viewRouter.buildChatView(page: page)
                    }
            }
        }
    }
}
