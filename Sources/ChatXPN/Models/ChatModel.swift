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

    enum CodingKeys: String, CodingKey {
        case id
        case users
        case lastMessage
        case image
        case uids
    }

    public init(id: String?, users: [ChatUser], lastMessage: ChatMessagePreview, image: String, uids: [String]) {
        self.id = id
        self.users = users
        self.lastMessage = lastMessage
        self.image = image
        self.uids = uids
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.users = try container.decode([ChatUser].self, forKey: .users)
        self.lastMessage = try container.decode(ChatMessagePreview.self, forKey: .lastMessage)
        self.image = try container.decode(String.self, forKey: .image)
        self.uids = try container.decode([String].self, forKey: .uids)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.users, forKey: .users)
        try container.encode(self.lastMessage, forKey: .lastMessage)
        try container.encode(self.image, forKey: .image)
        try container.encode(self.uids, forKey: .uids)
    }
}

public struct ChatMessagePreview: Identifiable, Codable, Equatable, Hashable {
    public var id: String?
    var type: MessageType
    var content: String
    var sentBy: String
    var seenBy: [String]
    var status: MessageStatus
    var createdAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case sentBy
        case seenBy
        case status
        case createdAt
    }

    public init(id: String?, type: MessageType, content: String, sentBy: String, seenBy: [String], status: MessageStatus, createdAt: Timestamp) {
        self.id = id
        self.type = type
        self.content = content
        self.sentBy = sentBy
        self.seenBy = seenBy
        self.status = status
        self.createdAt = createdAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try container.decode(MessageType.self, forKey: .type)
        self.content = try container.decode(String.self, forKey: .content)
        self.sentBy = try container.decode(String.self, forKey: .sentBy)
        self.seenBy = try container.decode([String].self, forKey: .seenBy)
        self.status = try container.decode(MessageStatus.self, forKey: .status)
        
        // Handle createdAt directly as Timestamp
        if let timestamp = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) {
            self.createdAt = timestamp
        } else {
            // Provide a default value if necessary
            self.createdAt = Timestamp(seconds: 0, nanoseconds: 0)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.sentBy, forKey: .sentBy)
        try container.encode(self.seenBy, forKey: .seenBy)
        try container.encode(self.status, forKey: .status)
        
        // Encode createdAt as Timestamp
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}

public struct ChatUser: Identifiable, Codable, Equatable, Hashable {
    public var id: String
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

func serializeChatModel(_ chatModel: ChatModel) -> String? {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(chatModel)
        return String(data: data, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    } catch {
        print("Failed to encode ChatModel: \(error)")
        return nil
    }
}

func deserializeChatModel(from jsonString: String) -> ChatModel? {
    let decoder = JSONDecoder()
    guard let decodedString = jsonString.removingPercentEncoding,
          let data = decodedString.data(using: .utf8) else {
        print("Failed to decode string: \(jsonString)")
        return nil
    }
    do {
        return try decoder.decode(ChatModel.self, from: data)
    } catch {
        print("Failed to decode ChatModel: \(error)")
        return nil
    }
}
