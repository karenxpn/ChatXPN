//
//  ChatModel.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

public struct ChatModel: Identifiable, Codable, Equatable, Hashable {
    @DocumentID public var id: String?
    var users: [ChatUser]
    var lastMessage: ChatMessagePreview
    var image: String
    var uids: [String]
}

struct ChatMessagePreview: Identifiable, Codable, Equatable, Hashable {
    var id: String?
    var type: MessageType
    var content: String
    var sentBy: String
    var seenBy: [String]
    var status: MessageStatus
    var createdAt: Timestamp
}

struct ChatUser: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var isAdmin: Bool
}


public struct ChatModelViewModel: Identifiable, Equatable, Hashable {
    var chat: ChatModel
    init(chat: ChatModel) {
        self.chat = chat
    }
    
    public var id: String   { self.chat.id ?? UUID().uuidString }
    var image: String       { self.chat.image }
    
    var name: String {
        if let user = self.chat.users.first(where: {$0.id != Auth.auth().currentUser?.uid }) { return user.name.isEmpty ? ((user.isAdmin) ? "Admin" : "User") : user.name }
        return ""
    }
    
    var isMessageReceived: Bool             { self.chat.lastMessage.sentBy != Auth.auth().currentUser?.uid }

    var messageStatus: MessageStatus        { self.chat.lastMessage.status }
    var messageType: MessageType            { self.chat.lastMessage.type }
    
    var seen: Bool {
        if self.chat.lastMessage.seenBy.contains(where: {$0 != self.chat.lastMessage.sentBy }) { return true }
        return false
    }
    
    var content: String {
        if messageType == .text {
            return self.chat.lastMessage.content
        } else if messageType == .call {
            return "videoCall"~
        } else {
            return "mediaContent"~
        }
    }
    
    var date: String                    { self.chat.lastMessage.createdAt.dateValue().countTimeBetweenDates() }
    var users: [ChatUser]               { self.chat.users }
    var lastMessage: ChatMessagePreview { self.chat.lastMessage }
}
