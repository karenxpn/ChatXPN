//
//  File.swift
//  
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
public enum ChatPath: Equatable, Hashable {
    case chat(apiKey: String)
    case chatRoom(chat: ChatModelViewModel, apiKey: String)
}
