//
//  ChatViewModel.swift
//  
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import NotraAuth

public class ChatViewModel: AlertViewModel, ObservableObject {
    @Published var loading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    @Published var chats = [ChatModelViewModel]()
    
    var manager: ChatServiceProtocol
    public init(manager: ChatServiceProtocol = ChatService.shared) {
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
    
    @MainActor public func getChatByID(chatID: String, completion: @escaping(ChatModelViewModel) -> ()) {
        loading = true
        Task {
            let result = await manager.getChatByID(chatID: chatID)
            switch result {
            case .failure(let error):
                self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
            case .success(let chat):
                completion(ChatModelViewModel(chat: chat))
            }
            if !Task.isCancelled {
                loading = false
            }
        }
    }
    
    @MainActor public func checkChatExistence(chatID: String, completion: @escaping(Bool) -> ()) {
        Task {
            let result = await manager.checkChatExistence(chatID: chatID)
            switch result {
            case .failure(_):
                break
            case .success(let exists):
                completion(exists)
            }
        }
    }
}
