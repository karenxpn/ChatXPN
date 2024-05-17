//
//  MessageBar.swift
//
//
//  Created by Karen Mirakyan on 15.05.24.
//

import SwiftUI
import CameraXPN
import PDFKit

struct MessageBar: View {
    @EnvironmentObject var roomVM: RoomViewModel
    
    @State private var openAttachment: Bool = false
    @State private var openGallery: Bool = false
    @State private var openCamera: Bool = false
    @State private var openFileImporter: Bool = false
    
    
    var body: some View {
        VStack( spacing: 0) {
            
            if roomVM.replyMessage != nil {
                BarMessagePreview(message: $roomVM.replyMessage)
            }
            
            HStack {
                Button {
                    openAttachment.toggle()
                } label: {
                    Image("icon_attachment", bundle: .module)
                        .tint(.primary)
                        .padding([.leading, .vertical], 20)
                }
                
                TextField(NSLocalizedString("messageBarPlaceholder", bundle: .module, comment: ""), text: $roomVM.message, axis: .vertical)
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
        }
        .confirmationDialog("", isPresented: $openAttachment, titleVisibility: .hidden) {
            Button {
                openGallery.toggle()
            } label: {
                Text(NSLocalizedString("loadFromGallery", bundle: .module, comment: ""))
            }
            
            Button {
                openCamera.toggle()
            } label: {
                Text(NSLocalizedString("openCamera", bundle: .module, comment: ""))
            }
            
            Button {
                openFileImporter.toggle()
            } label: {
                Text(NSLocalizedString("openDocuments", bundle: .module, comment: ""))
            }
        }.sheet(isPresented: $openGallery) {
            MessageGallery { content_type, content in
                roomVM.media = content
                roomVM.sendMessage(messageType: .photo)
            }
        }.fullScreenCover(isPresented: $openCamera, content: {
            CameraXPN(action: { url, data in
                roomVM.media = data
                //                roomVM.sendMessage(messageType: url.absoluteString.hasSuffix(".mov") ? .video : .photo)
            }, font: .custom("Inter-SemiBold", size: 14), permissionMessage: "enableAccessForBoth",
                      recordVideoButtonColor: .primary,
                      useMediaContent: NSLocalizedString("useThisMedia", bundle: .module, comment: ""), videoAllowed: false)
            
        }).fileImporter(isPresented: $openFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
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
