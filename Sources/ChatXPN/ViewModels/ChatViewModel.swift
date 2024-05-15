//
//  ChatViewModel.swift
//  
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import NotraAuth

class ChatViewModel: AlertViewModel, ObservableObject {
    @Published var loading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    @Published var chats = [ChatModelViewModel]()
    
    var manager: ChatServiceProtocol
    init(manager: ChatServiceProtocol = ChatService.shared) {
        self.manager = manager
    }
    
    @MainActor func getChats() {
        loading = true
        manager.fetchChatList { result in
            switch result {
            case .failure(let error):
                self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
            case .success(let chats):
                self.chats = chats.map(ChatModelViewModel.init)
            }
            
            self.loading = false
        }
    }
}
