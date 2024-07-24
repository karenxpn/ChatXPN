//
//  MessageModel.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

public struct MessageModel: IdentifiableDocument {
    @DocumentID public var id: String?
    var createdAt: Timestamp
    var type: MessageType
    var callEnded: Bool?
    var content: String
    var sentBy: String
    var seenBy: [String]
    var status: MessageStatus
    var repliedTo: RepliedMessageModel?
    var reactions: [ReactionModel]
    var senderName: String?
}

public struct ReactionModel: Codable, Equatable {
    var userId: String
    var reaction: String
}


struct MessageViewModel: Identifiable {
    
    var message: MessageModel
    init(message: MessageModel) {
        self.message = message
    }
    
    var id: String                              { self.message.id ?? "" }
    var creationDate: Timestamp                 { self.message.createdAt}
    var createdAt: String                       { self.message.createdAt.dateValue().countTimeBetweenDates() }
    var timestamp: Timestamp                    { self.message.createdAt }
    var type: MessageType                       { self.message.type }
    var callEnded: Bool?                        { self.message.callEnded }
    var content: String                         { self.message.content }
    var sentBy: String                          { self.message.sentBy }
    var received: Bool                          { self.message.sentBy != Auth.auth().currentUser?.uid }
    var seen: Bool                              { self.message.seenBy.contains(where: {$0 != sentBy})}
    var seenBy: [String]                        { self.message.seenBy }
    var status: MessageStatus                   { self.message.status }
    var reactionModels: [ReactionModel]         { self.message.reactions }
    var repliedTo: RepliedMessageModel?         { self.message.repliedTo }
    var senderName: String                      { self.message.senderName ?? "User" }
}
