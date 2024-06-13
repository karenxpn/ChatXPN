//
//  RoomViewModel.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import NotraAuth
import FirebaseFirestore
import FirebaseAuth

class RoomViewModel: AlertViewModel, ObservableObject {
    @Published var loading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var loadingCall: Bool = false
    
    @Published var message: String = ""
    @Published var media: Data?
    
    @Published var chatID: String = ""
    @Published var lastMessage: QueryDocumentSnapshot?
    @Published var messages = [MessageViewModel]()
    private var cachedMessages: [String: MessageViewModel] = [:]
    
    @Published var replyMessage: MessageViewModel?
    
    @Published var token: String?
    @Published var joiningCall: Bool = false
    
    var manager: ChatServiceProtocol
    init(manager: ChatServiceProtocol = ChatService.shared) {
        self.manager = manager
    }
    
    @MainActor func getMessages() {
        loading = true
        manager.fetchMessages(chatID: chatID, lastMessage: lastMessage) { result in
            switch result {
            case .failure(let error):
                self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
            case .success((let messages, let lastMessage)):
                self.updateCachedMessages(with: messages.map(MessageViewModel.init))
                self.messages = Array(self.cachedMessages.values)
                self.messages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
                self.lastMessage = lastMessage
            }
            self.loading = false
        }
    }
    
    @MainActor func sendMessage(messageType: MessageType) {
        var sendingMessage = message
        message = ""
        
        Task {
            if let media {
                if messageType != .text {
                    let messageID = addLocalMediaMessage(messageType: messageType)
                    
                    let mediaUploadResult = await manager.uploadMedia(media: media, type: messageType)
                    switch mediaUploadResult {
                    case .success(let url):
                        sendingMessage = url
                        self.cachedMessages.removeValue(forKey: messageID)
                    case .failure(let error):
                        self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
                    }
                }
            }
            
            let replyTo = replyMessage != nil ? RepliedMessageModel(message: replyMessage!.content,
                                                                    type: replyMessage!.type,
                                                                    name: replyMessage!.senderName) : nil
            self.replyMessage = nil
            
            
            let result = await manager.sendMessage(chatID: chatID, type: messageType, content: sendingMessage, repliedTo: replyTo)
            
            switch result {
            case .success(()):
                sendingMessage = ""
            case .failure(let error):
                self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
            }
        }
    }
    
    func addLocalMediaMessage(messageType: MessageType) -> String {
        let messageID = UUID().uuidString
        let sender = Auth.auth().currentUser?.uid ?? ""
        
        let mediaMessage = MessageModel(id: messageID,
                                        createdAt: Timestamp(date: .now),
                                        type: messageType,
                                        content: media!.base64EncodedString(),
                                        sentBy: sender,
                                        seenBy: [sender],
                                        status: .pending,
                                        reactions: [])
        
        self.updateCachedMessages(with: [MessageViewModel(message: mediaMessage)])
        self.messages = Array(self.cachedMessages.values)
        self.messages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        
        return messageID
    }
    
    @MainActor func deleteMessage(messageID: String) {
        Task {
            let _ = await manager.editMessage(chatID: chatID,
                                              messageID: messageID,
                                              message: "This message was deleted ☹︎",
                                              status: .deleted)
        }
    }
    
    @MainActor func sendReaction(message: MessageViewModel, reaction: String) {
        Task {
            var action = ReactionAction.react
            let reaction = ReactionModel(userId: Auth.auth().currentUser?.uid ?? "", reaction: reaction)
            if message.reactionModels.contains(where: { $0 == reaction}) {
                action = .remove
            }
            
            let _ = await manager.sendReaction(chatID: chatID,
                                               messageID: message.id,
                                               reaction: reaction,
                                               action: action)
        }
    }
    
    @MainActor func markMessageRead(messageID: String) {
        Task {
            let _ = await manager.markMessageAsRead(chatID: chatID, messageID: messageID)
        }
    }
    
    @MainActor func getThumbnail(url: String?, media: Data?, width: CGFloat, completion: @escaping (UIImage?) -> ()) {
        Task {
            let thumbnail = await manager.pdfThumbnail(url: URL(string: url ?? ""), media: media, width: width)
            completion(thumbnail)
        }
    }
    
    @MainActor func getToken(completion: @escaping(String?) -> ()) {
        loadingCall = true
        Task {
            do {
                let result = try await manager.fetchToken()
                completion(result.token)
            } catch {
                print(error)
                self.makeAlert(with: error, message: &self.alertMessage, alert: &self.showAlert)
                completion(nil)
            }
            
            if !Task.isCancelled {
                loadingCall = false
            }
        }
    }
    
    private func updateCachedMessages(with newMessages: [MessageViewModel]) {
        // Iterate through the new messages
        for message in newMessages {
            // Update the message in the cache
            cachedMessages[message.id] = message
        }
    }
}
