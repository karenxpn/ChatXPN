//
//  File.swift
//  
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
enum ChatPath: Equatable, Hashable {
    case chat
    case chatRoom(chat: ChatModelViewModel)
}
