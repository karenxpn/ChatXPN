//
//  File.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import FirebaseFirestore

struct PreviewModels {
    static let chatUser = ChatUser(id: UUID().uuidString, name: "Karen Mirakyan", isAdmin: false)
    static let chatAdminUser = ChatUser(id: UUID().uuidString, name: "Support John", isAdmin: true)
    static let lastMessage = ChatMessagePreview(id: UUID().uuidString, type: .text, content: "Hi, can you help me with my doc?", sentBy: "", seenBy: [chatUser.id, chatAdminUser.id], status: .read, createdAt: Timestamp(date: Date()))
    
    static let chats = [
        ChatModelViewModel(chat: ChatModel(id: UUID().uuidString,
                                           users: [chatUser, chatAdminUser],
                                           lastMessage: lastMessage,
                                           image: "",
                                           uids: [chatUser.id, chatAdminUser.id])),
        
        ChatModelViewModel(chat: ChatModel(id: UUID().uuidString,
                                           users: [chatUser, chatAdminUser],
                                           lastMessage: lastMessage,
                                           image: "",
                                           uids: [chatUser.id, chatAdminUser.id])),
        
        ChatModelViewModel(chat: ChatModel(id: UUID().uuidString,
                                           users: [chatUser, chatAdminUser],
                                           lastMessage: lastMessage,
                                           image: "",
                                           uids: [chatUser.id, chatAdminUser.id])),
    ]
    
    static let message = MessageViewModel(message: MessageModel(id: UUID().uuidString,
                                                                createdAt: Timestamp(date: Date().toGlobalTime()),
                                                                type: .text,
                                                                content: "Hello my name is Karen",
                                                                sentBy: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92",
                                                                seenBy: ["yo1NBb8aLlPbC1wJE5pdeJ4fZC92"],
                                                                status: .sent, reactions: []))
    
    static let emojiMessage = MessageViewModel(message: MessageModel(id: UUID().uuidString,
                                                                     createdAt: Timestamp(date: Date().toGlobalTime()),
                                                                     type: .text,
                                                                     content: "💰",
                                                                     sentBy: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92",
                                                                     seenBy: ["yo1NBb8aLlPbC1wJE5pdeJ4fZC92"],
                                                                     status: .sent, reactions: [ReactionModel(userId: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92", reaction: "👍")]))
    
    static let photoMessage = MessageViewModel(message: MessageModel(id: UUID().uuidString,
                                                                     createdAt: Timestamp(date: Date().toGlobalTime()),
                                                                     type: .photo,
                                                                     content: "https://s3-alpha-sig.figma.com/img/c252/0419/27718eefce1789c59499f91fec79c8b2?Expires=1715558400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Ck-kLFxqTqKNE~c5z06Igcy0tEc-iDO9IEngHEic~wDEe67QZee9Jpu4vn0qmVbVGWQXvTrQbgcLmtLj8u5JDDorY67sDBV5VbxBLCXXa6DP2sNU1k4UH2FAAay8Hf-wXoS~YLJ73qtocXk3cvYgyt8NFhVPWtxzlfGWLdqGAXdLsjOGps3NwEKzpXIhHS~XbtoDWfBQ21uVjPgE3VOELn8CeYT~4A79fl3ZYNNLOJXvVhrcPAIjI8tJ~y6~kSCGy-JUKjSWgLTnYUFDP8K2nrlB649NnYsbaqrJ42bdrMqXxWjYJYjZCo-oVa8AglKXdQYX1EyExjc3Mmjoz4HF0w__",
                                                                     sentBy: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92",
                                                                     seenBy: ["yo1NBb8aLlPbC1wJE5pdeJ4fZC92"],
                                                                     status: .sent, reactions: []))
    
    static let callMessage = MessageViewModel(message: MessageModel(id: UUID().uuidString,
                                                                    createdAt: Timestamp(date: Date().toGlobalTime()),
                                                                    type: .call,
                                                                    callEnded: false,
                                                                    content: "Call",
                                                                    sentBy: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92",
                                                                    seenBy: ["yo1NBb8aLlPbC1wJE5pdeJ4fZC92"],
                                                                    status: .sent, reactions: [ReactionModel(userId: "yo1NBb8aLlPbC1wJE5pdeJ4fZC92", reaction: "👍")]))
}
