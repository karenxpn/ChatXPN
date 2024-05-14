//
//  ChatService.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import NotraAuth
import FirebaseStorage
import DataCache
import SwiftUI
import PDFKit


protocol ChatServiceProtocol {
    func fetchChatList(completion: @escaping (Result<[ChatModel], Error>) -> ())
    func fetchMessages(chatID: String, lastMessage: QueryDocumentSnapshot?, completion: @escaping(Result<([MessageModel], QueryDocumentSnapshot?), Error>) -> ())
    
    
    func sendMessage(chatID: String,
                     type: MessageType,
                     content: String,
                     repliedTo: RepliedMessageModel?) async -> Result<Void, Error>
    func uploadMedia(media: Data, type: MessageType) async -> Result<String, Error>
    func editMessage(chatID: String, messageID: String, message: String, status: MessageStatus) async -> Result<Void, Error>
    func sendReaction(chatID: String, messageID: String, reaction: ReactionModel, action: ReactionAction) async -> Result<Void, Error>
    func markMessageAsRead(chatID: String, messageID: String) async -> Result<Void, Error>
    
    func pdfThumbnail(url: URL?, media: Data?, width: CGFloat) async -> UIImage?
}

class ChatService {
    static let shared: ChatServiceProtocol = ChatService()
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    private init() { }
}

extension ChatService: ChatServiceProtocol {
    
    func pdfThumbnail(url: URL?, media: Data?, width: CGFloat) async -> UIImage? {
        do {
            
            if let url, let image = DataCache.instance.readImage(forKey: url.absoluteString + "thumbnail") {
                print("returned thumbnail from cached url ")
                return image
            }
            
            print("not found the url of cached thumbnail")
            
            var page: PDFPage?
            if let media {
                page = PDFDocument(data: media)?.page(at: 0)
            } else {
                let data = try Data(contentsOf: url!)
                page = PDFDocument(data: data)?.page(at: 0)
            }
            
            guard let page = page else {
                print("return nil")
                return nil }
            
            let pageSize = page.bounds(for: .mediaBox)
            let pdfScale = width / pageSize.width
            
            // Apply if you're displaying the thumbnail on screen
            let scale = await UIScreen.main.scale * pdfScale
            let screenSize = CGSize(width: pageSize.width * scale,
                                    height: pageSize.height * scale)
            
            let thumbnail = page.thumbnail(of: screenSize, for: .mediaBox)
            
            if let url {
                DataCache.instance.write(image: thumbnail, forKey: url.absoluteString + "thumbnail")
                print("thumbnail cached to the url \(url)")
            }
            
            return thumbnail
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    
    func markMessageAsRead(chatID: String, messageID: String) async -> Result<Void, Error> {
        return await APIHelper.shared.voidRequest(action: {
            
            guard let userID = Auth.auth().currentUser?.uid else {
                throw CustomErrors.userNotFound
            }
            
            try await db.collection(Paths.chats.rawValue)
                .document(chatID)
                .collection(Paths.messages.rawValue)
                .document(messageID)
                .updateData(["seenBy" : FieldValue.arrayUnion([userID]),
                             "status": MessageStatus.read.rawValue])
            
            let chat = try await db.collection(Paths.chats.rawValue)
                .document(chatID)
                .getDocument(as: ChatModel.self)
            
            if messageID == chat.lastMessage.id && !chat.lastMessage.seenBy.contains(where: {$0 == userID}) {
                print("updating last message")
                try await db.collection(Paths.chats.rawValue)
                    .document(chatID)
                    .updateData(["lastMessage.seenBy": FieldValue.arrayUnion([userID]),
                                 "lastMessage.status": MessageStatus.read.rawValue])
            }
        })
    }
    
    func sendReaction(chatID: String, messageID: String, reaction: ReactionModel, action: ReactionAction) async -> Result<Void, Error> {
        return await APIHelper.shared.voidRequest {
            try await db.collection(Paths.chats.rawValue)
                .document(chatID)
                .collection(Paths.messages.rawValue)
                .document(messageID)
                .updateData(["reactions": action == .react ?
                             FieldValue.arrayUnion([["userId" : reaction.userId,
                                                     "reaction" : reaction.reaction]]) :
                                FieldValue.arrayRemove([["userId": reaction.userId,
                                                         "reaction": reaction.reaction]])])
        }
    }
    
    func editMessage(chatID: String, messageID: String, message: String, status: MessageStatus) async -> Result<Void, Error> {
        
        return await APIHelper.shared.voidRequest {
            let _ = try await db.collection(Paths.chats.rawValue)
                .document(chatID)
                .collection(Paths.messages.rawValue)
                .document(messageID)
                .setData(["content" : message,
                          "isEdited": true,
                          "status": status.rawValue,
                          "type": MessageType.text.rawValue], merge: true)
        }
    }
    
    func fetchMessages(chatID: String, lastMessage: QueryDocumentSnapshot?, completion: @escaping (Result<([MessageModel], QueryDocumentSnapshot?), Error>) -> ()) {
        
        guard let _ = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                completion(.failure(CustomErrors.userNotFound))
            }
            return
        }
        
        var query: Query = db.collection(Paths.chats.rawValue)
            .document(chatID)
            .collection(Paths.messages.rawValue)
            .order(by: "createdAt", descending: true)
        
        if lastMessage == nil {
            let currentQuery = query.limit(to: 50)
            currentQuery.getDocuments { snapshot, error in
                if let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                let last = snapshot!.documents.last
                if let last { query = query.end(atDocument: last) }
                
                APIHelper.shared.paginatedSnapshotListener(query: query) { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            }
            
        } else {
            query = query.start(afterDocument: lastMessage!).limit(to: 50)
            APIHelper.shared.paginatedSnapshotListener(query: query) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    
    func uploadMedia(media: Data, type: MessageType) async -> Result<String, Error> {
        do {
            var fileExtension = ""
            if type == .photo       { fileExtension = "jpg" }
            else if type == .file   { fileExtension = "pdf"}
            
            let dbRef = storageRef.child("chats/\(UUID().uuidString).\(fileExtension)")
            let _ = try await dbRef.putDataAsync(media)
            let url = try await dbRef.downloadURL().absoluteString
            
            if type == .photo {
                DataCache.instance.write(image: UIImage(data: media) ?? UIImage(), forKey: url)
            } else {
                DataCache.instance.write(data: media, forKey: url)
                let _ = await self.pdfThumbnail(url: URL(string: url)!, media: nil, width: 100)
            }
            
            return .success(url)
        } catch {
            return .failure(error)
        }
    }
    
    func sendMessage(chatID: String, type: MessageType, content: String, repliedTo: RepliedMessageModel?) async -> Result<Void, any Error> {
        return await APIHelper.shared.voidRequest {
            guard let userID = Auth.auth().currentUser?.uid else {
                throw CustomErrors.userNotFound
            }
            
            let message = MessageModel(createdAt: Timestamp(date: Date().toGlobalTime()),
                                       type: type,
                                       content: content,
                                       sentBy: userID,
                                       seenBy: [userID],
                                       status: .sent,
                                       repliedTo: repliedTo,
                                       reactions: [],
                                       senderName: Auth.auth().currentUser?.displayName)
            
            let sentMessage = try await db
                .collection(Paths.chats.rawValue)
                .document(chatID)
                .collection(Paths.messages.rawValue)
                .addDocument(data: Firestore.Encoder().encode(message))
            
            let curMessage = try await sentMessage.getDocument(as: MessageModel.self)
            
            let lastMessage = ChatMessagePreview(id: curMessage.id,
                                                 type: curMessage.type,
                                                 content: curMessage.content,
                                                 sentBy: curMessage.sentBy,
                                                 seenBy: curMessage.seenBy,
                                                 status: curMessage.status,
                                                 createdAt: curMessage.createdAt)
            
            try await db.collection(Paths.chats.rawValue)
                .document(chatID)
                .setData(["lastMessage": Firestore.Encoder().encode(lastMessage)], merge: true)
        }
    }
    
    func fetchChatList(completion: @escaping (Result<[ChatModel], any Error>) -> ()) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                completion(.failure(CustomErrors.userNotFound))
            }
            return
        }
        
        let query = db.collection(Paths.chats.rawValue)
            .whereField("uids", arrayContains: userID)
            .order(by: "lastMessage.createdAt", descending: true)
        
        
        APIHelper.shared.snapshotListener(query: query) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
