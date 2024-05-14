//
//  Enums.swift
//  
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation

enum MessageType : RawRepresentable, CaseIterable, Codable, Equatable, Hashable {
    
    typealias RawValue = String
    
    case text
    case photo
    case file
    case unknown(RawValue)
    
    static let allCases: AllCases = [
        .text,
        .photo,
        .file,
    ]
    
    init(rawValue: RawValue) {
        self = Self.allCases.first{ $0.rawValue == rawValue }
        ?? .unknown(rawValue)
    }
    
    var rawValue: RawValue {
        switch self {
        case .text                  : return "text"
        case .photo                 : return "photo"
        case .file                  : return "file"
        case let .unknown(value)    : return value
        }
    }
}


enum MessageStatus : RawRepresentable, CaseIterable, Codable, Equatable, Hashable {
    
    typealias RawValue = String
    
    case pending
    case sent
    case read
    case deleted
    case unknown(RawValue)
    
    static let allCases: AllCases = [
        .pending,
        .sent,
        .read,
        .deleted
    ]
    
    init(rawValue: RawValue) {
        self = Self.allCases.first{ $0.rawValue == rawValue }
        ?? .unknown(rawValue)
    }
    
    var rawValue: RawValue {
        switch self {
        case .pending               : return "pending"
        case .sent                  : return "sent"
        case .read                  : return "read"
        case .deleted               : return "deleted"
        case let .unknown(value)    : return value
        }
    }
}
