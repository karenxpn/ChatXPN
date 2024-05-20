//
//  RepliedMessageModel.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
public struct RepliedMessageModel: Codable {
    var message: String
    var type: MessageType
    var name: String
}
