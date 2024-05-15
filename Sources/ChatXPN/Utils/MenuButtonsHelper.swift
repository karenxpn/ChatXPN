//
//  MenuButtonsHelper.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import Foundation
import NotraAuth
import SwiftUI

struct MenuButtonsHelper: View {
    let label: String
    let icon: String
    let role: ButtonRole
    let action: (() -> Void)

    var body: some View {
        
        Button {
            action()
        } label: {
            
            HStack {
                TextHelper(text: label, color: role == .destructive ? Color.red : .primary, fontSize: 12)
                
                Spacer()
                
                Image(systemName: icon)
                    .tint(role == .destructive ? Color.red : .primary)
                                    
            }.frame(height: 37)
                .padding(.horizontal)
                .background(Color("messageMenu", bundle: .module))
        }
    }
}
