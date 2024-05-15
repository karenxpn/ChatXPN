// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct ChatXPN: View {
    @EnvironmentObject private var viewRouter: ChatViewRouter
    public init() { }
    
    public var body: some View {
        NavigationStack(path: $viewRouter.chatPath) {
            Chat()
                .navigationDestination(for: ChatPath.self) { page in
                    viewRouter.buildChatView(page: page)
                }
        }
    }
}
