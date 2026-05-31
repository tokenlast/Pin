import SwiftUI

@main
struct PensRecorderApp: App {
    @StateObject private var recorder = AudioRecorder()

    var body: some Scene {
        WindowGroup {
            ContentView(recorder: recorder)
                .onOpenURL { url in
                    guard url.scheme == "pin" else { return }
                    if url.host == "toggle" || url.path == "/toggle" {
                        recorder.toggleFromWidget()
                    }
                }
        }
    }
}
