//
//  FileMessageContent.swift
//  NotraLaw
//
//  Created by Karen Mirakyan on 13.05.24.
//

import SwiftUI
import DataCache

struct FileMessageContent: View {
    @EnvironmentObject var roomVM: RoomViewModel
    let message: MessageViewModel
    @State private var loading: Bool = false
    @State private var thumbnail: UIImage?
    
    var body: some View {
        
        VStack( alignment: !message.received ? .trailing : .leading) {
            
            HStack(alignment: .bottom, spacing: 8) {
                
                Image(uiImage: thumbnail ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if message.status == .pending && !message.received {
                            ProgressView()
                                .tint(.gray)
                        } else {
                            EmptyView()
                        }
                    }
                
                if !message.received && message.status != .pending {
                    Image(message.seen ? "read_icon" : "sent_icon", bundle: .module)
                        .foregroundStyle(Color("sentRead", bundle: .module))
                        .scaleEffect(1.2)
                }
            }
        }.padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(!message.received ? Color("turquoise", bundle: .module) : Color("tabShadow", bundle: .module))
            .cornerRadius(20, corners: !message.received ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            .task {
                roomVM.getThumbnail(url: message.content.hasPrefix("https://") ? message.content : nil, 
                                    media: (message.status == .pending && !message.received) ? Data(base64Encoded: message.content)  : nil,
                                    width: 100) { uiImage in
                    self.thumbnail = uiImage
                }
            }
    }
}

//#Preview {
//    FileMessageContent()
//}
