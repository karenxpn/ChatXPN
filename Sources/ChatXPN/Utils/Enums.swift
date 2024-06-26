//
//  Enums.swift
//  
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation

public enum MessageType : RawRepresentable, CaseIterable, Codable, Equatable, Hashable {
    
    public typealias RawValue = String
    
    case text
    case photo
    case file
    case call
    case unknown(RawValue)
    
    public static let allCases: AllCases = [
        .text,
        .photo,
        .file,
        .call,
    ]
    
    public init(rawValue: RawValue) {
        self = Self.allCases.first{ $0.rawValue == rawValue }
        ?? .unknown(rawValue)
    }
    
    public var rawValue: RawValue {
        switch self {
        case .text                  : return "text"
        case .photo                 : return "photo"
        case .file                  : return "file"
        case .call                  : return "call"
        case let .unknown(value)    : return value
        }
    }
}


public enum MessageStatus : RawRepresentable, CaseIterable, Codable, Equatable, Hashable {
    
    public typealias RawValue = String
    
    case pending
    case sent
    case read
    case deleted
    case unknown(RawValue)
    
    public static let allCases: AllCases = [
        .pending,
        .sent,
        .read,
        .deleted
    ]
    
    public init(rawValue: RawValue) {
        self = Self.allCases.first{ $0.rawValue == rawValue }
        ?? .unknown(rawValue)
    }
    
    public var rawValue: RawValue {
        switch self {
        case .pending               : return "pending"
        case .sent                  : return "sent"
        case .read                  : return "read"
        case .deleted               : return "deleted"
        case let .unknown(value)    : return value
        }
    }
}

public enum ReactionAction {
    case remove, react
}

enum Paths : RawRepresentable, CaseIterable, Codable {
    
    typealias RawValue = String
    
    
    case users
    case userBalance
    case documents
    case chats
    case messages
    case unknown(RawValue)
    
    static let allCases: AllCases = [
        .users,
        .userBalance,
        .documents,
        .chats,
        .messages
    ]
    
    init(rawValue: RawValue) {
        self = Self.allCases.first{ $0.rawValue == rawValue }
        ?? .unknown(rawValue)
    }
    
    var rawValue: RawValue {
        switch self {
        case .userBalance                       : return "user_balance"
        case .users                             : return "users"
        case .documents                         : return "documents"
        case .chats                             : return "chats"
        case .messages                          : return "messages"
        case let .unknown(value)                : return value
        }
    }
}

enum FullScreenTypeEnum: Identifiable {
    case media(url: URL, type: MessageType)
    case call(token: String, callId: String, users: [ChatUser])
    case camera
    
    var id: String {
        switch self {
        case .media(let url, let type):
            return "media-\(url.absoluteString)-\(type)"
        case .call(_, let callId, _):
            return callId
        case .camera:
            return "camera"
        }
    }
}
