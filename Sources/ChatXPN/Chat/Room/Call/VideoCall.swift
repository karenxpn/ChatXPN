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
    @StateObject private var viewModel: CallViewModel
    @Environment(\.dismiss) var dismiss
    private var client: StreamVideoUI
    
    private let apiKey: String
    private let userId: String = Auth.auth().currentUser?.uid ?? ""
    private let callId: String
    private let create: Bool
    private let members: [Member]
    private let endCall: (String) -> ()
    
    @State private var eventSubscriptionTask: Task<Void, Error>?
    
    init(
        token: String,
        callId: String,
        apiKey: String,
        users: [ChatUser],
        create: Bool = true,
        endCall: @escaping(String) -> ()
    ) {
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
        
        self.client = StreamVideoUI(
            streamVideo: StreamVideo(
                apiKey: apiKey,
                user: user,
                token: .init(stringLiteral: token)
            ),
            appearance: customAppearance
        )
        
        let callViewModel = CallViewModel()
        callViewModel.participantAutoLeavePolicy = LastParticipantAutoLeavePolicy()
        _viewModel = .init(wrappedValue: callViewModel)
        
        print("initialized the video call view")
    }
    
    var body: some View {
        VStack {
            if viewModel.call != nil {
                CallContainer(viewFactory: DefaultViewFactory.shared, viewModel: viewModel)
            } else {
                Text("loading"~)
            }
        }.task {
            guard viewModel.call == nil, create else { return }
            viewModel.startCall(callType: .default, callId: callId, members: members, ring: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .init(CallNotification.callEnded))) { _ in dismiss() }
        .onReceive(viewModel.$callingState.map {
            print("the calling state is \($0)")
            switch $0 {
            case .incoming:     return true
            default:            return false
            }
        }) { hasIncomingCall in
            guard hasIncomingCall else { return }
            viewModel.acceptCall(callType: .default, callId: callId)
        }
        .onReceive(viewModel.$call, perform: { newCall in
            eventSubscriptionTask?.cancel()
            eventSubscriptionTask = nil
            
            guard let newCall else { return }
            subscribeToCallEvents(on: newCall)
        })
        .alert("error"~, isPresented: $viewModel.errorAlertShown, actions: {
            Button("ok"~, role: .cancel) { dismiss() }
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "")
        })
    }
    
    private func subscribeToCallEvents(on call: Call) {
        eventSubscriptionTask = Task {
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
