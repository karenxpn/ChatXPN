//
//  MessageBar.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI
import PDFKit

struct MessageBar: View {
    @EnvironmentObject var roomVM: RoomViewModel
    
    @State private var openGallery: Bool = false
    @State private var openFileImporter: Bool = false
    
    var body: some View {
        VStack( spacing: 0) {
            
            if roomVM.replyMessage != nil {
                BarMessagePreview(message: $roomVM.replyMessage)
            }
            
            HStack {
                Menu {
                    Button {
                        openGallery.toggle()
                    } label: {
                        Label("loadFromGallery"~, systemImage: "photo")
                    }
                    
                    Button {
                        roomVM.fullScreen = .camera
                    } label: {
                        Label("openCamera"~, systemImage: "camera")
                    }
                    
                    Button {
                        openFileImporter.toggle()
                    } label: {
                        Label("openDocuments"~, systemImage: "doc.on.doc")
                    }
                } label: {
                    Image("icon_attachment", bundle: .module)
                        .tint(.primary)
                        .padding([.leading], 20)
                }
                
                TextField("messageBarPlaceholder"~, text: $roomVM.message, axis: .vertical)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                    .font(.custom("SF Pro Text", size: 13))
                    .frame(height: 60)
                    .padding(.horizontal, 20)
                
                Button {
                    roomVM.sendMessage(messageType: .text)
                } label: {
                    Image("icon_send_message", bundle: .module)
                        .padding([.trailing, .vertical], 20)
                        .opacity(roomVM.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }.disabled(roomVM.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
            }.frame(height: 80)
                .background(Color("messageBar", bundle: .module))
                .cornerRadius(roomVM.replyMessage != nil ? 0 : 35, corners: [.topLeft, .topRight])
                .shadow(color: roomVM.replyMessage != nil ? Color.clear : Color.gray.opacity(0.1), radius: 2, x: 0, y: -3)
        }.sheet(isPresented: $openGallery) {
            MessageGallery { content_type, content in
                roomVM.media = content
                roomVM.sendMessage(messageType: .photo)
            }
        }.fileImporter(isPresented: $openFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
            switch result {
            case .failure(let error):
                roomVM.makeAlert(with: error, message: &roomVM.alertMessage, alert: &roomVM.showAlert)
                print(error.localizedDescription)
            case .success(let urls):
                do {
                    if let fileUrl = urls.first {
                        let gotAccess = fileUrl.startAccessingSecurityScopedResource()
                        if !gotAccess {
                            roomVM.alertMessage = "File access denied"
                            roomVM.showAlert.toggle()
                        }

                        let fileData = try Data(contentsOf: fileUrl)
                        roomVM.media = fileData
                        roomVM.sendMessage(messageType: .file)
                        
                        fileUrl.stopAccessingSecurityScopedResource()
                    } else {
                        print("file url not found")
                    }

                } catch {
                    roomVM.makeAlert(with: error, message: &roomVM.alertMessage, alert: &roomVM.showAlert)
                }
            }
        }
    }
}

#Preview {
    MessageBar()
        .environmentObject(RoomViewModel())
}
