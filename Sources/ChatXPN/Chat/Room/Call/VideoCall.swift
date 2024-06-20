//
//  VideoCall.swift
//
//
//  Created by Karen Mirakyan on 12.06.24.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI
import FirebaseAuth


struct VideoCall: View {
    @ObservedObject var viewModel: CallViewModel
    @Environment(\.dismiss) var dismiss
    
    
    private var client: StreamVideo
    
    private let apiKey: String
    private let userId: String = Auth.auth().currentUser?.uid ?? ""
    private let callId: String
    private let create: Bool
    private let members: [Member]
    private let endCall: (String) -> ()
    
    init(token: String, callId: String, apiKey: String, users: [ChatUser], create: Bool = true, endCall: @escaping(String) -> ()) {
        self.callId = callId
        self.create = create
        self.apiKey = apiKey
        self.members = users.map { Member(user: User(id: $0.id, name: $0.name)) }
        self.endCall = endCall
        
        let user = User(
            id: userId,
            name: Auth.auth().currentUser?.displayName ?? "User",
            imageURL: URL(string: "https://pixabay.com/vectors/blank-profile-picture-mystery-man-973460/")
        )
        
        let customSound = Sounds()
        // Tell the SDK to pick the custom ring tone
        customSound.bundle = Bundle.main
        // Swap the outgoing call sound with the custom one
        customSound.outgoingCallSound = "ringing.mp3"
        
        // Create an instance of the appearance class
        let customAppearance = Appearance(sounds: customSound)
        
        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )
        
        _ = StreamVideoUI(
            streamVideo: client,
            appearance: customAppearance
        )
        
        viewModel = .init()
        
        print("initialized the video call view")
    }
    
    var body: some View {
        VStack {
            if viewModel.call != nil {
                CallContainer(viewFactory: DefaultViewFactory.shared, viewModel: viewModel)
            } else {
                Text("loading...")
            }
        }.onAppear {
            Task {
                viewModel.participantAutoLeavePolicy = LastParticipantAutoLeavePolicy()
                
                guard viewModel.call == nil else { return }
                if create {
                    viewModel.startCall(callType: .default, callId: callId, members: members, ring: true)
                    if let call = viewModel.call {
                        print("subscribe to events")
                        for await event in call.subscribe(for: CallEndedEvent.self) {
                            print("call ended event", event)
                        }
                        
                        for await event in call.subscribe() {
                            print("event \(event)")
                        }
                    }
                } else {
                    viewModel.acceptCall(callType: .default, callId: callId)
                    if let call = viewModel.call {
                        print("subscribe to events")

                        for await event in call.subscribe(for: CallEndedEvent.self) {
                            print("call ended event", event)
                        }
                        
                        for await event in call.subscribe() {
                            print("event \(event)")
                        }
                    }
                }
                

            }
        }.onChange(of: viewModel.callingState) { oldValue, newValue in
            if newValue == .idle {
                print("participants \(viewModel.participants)")
                handleCallEnd()
            }
            print(newValue)
        }.alert("error"~, isPresented: $viewModel.errorAlertShown, actions: {
            Button("ok"~, role: .cancel) { dismiss() }
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "")
        })
    }
    
    private func handleCallEnd() {
        Task {
            viewModel.hangUp()
            print("hang up the call")
            endCall(callId) // Notify parent about the call end
            dismiss()
        }
    }
}
