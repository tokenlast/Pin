import SwiftUI

struct ContentView: View {
    @ObservedObject var recorder: AudioRecorder
    @State private var showingFolderPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 92, weight: .semibold))
                        .foregroundStyle(recorder.isRecording ? .red : .blue)
                        .symbolRenderingMode(.hierarchical)

                    Text(recorder.isRecording ? "Recording" : "Ready")
                        .font(.largeTitle.bold())

                    Text(recorder.statusText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                }

                Button {
                    recorder.toggleRecording()
                } label: {
                    Label(recorder.isRecording ? "Stop Recording" : "Start Recording",
                          systemImage: recorder.isRecording ? "stop.fill" : "record.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!recorder.canRecord)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Destination")
                        .font(.headline)

                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: recorder.hasDestination ? "folder.fill" : "folder.badge.questionmark")
                            .foregroundStyle(recorder.hasDestination ? .blue : .secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(recorder.destinationName)
                                .font(.body.weight(.medium))
                                .lineLimit(1)

                            Text(recorder.destinationDetail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }

                    Button {
                        showingFolderPicker = true
                    } label: {
                        Label("Choose Folder", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                if let lastSavedFile = recorder.lastSavedFile {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last Saved")
                            .font(.headline)
                        Text(lastSavedFile)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 16)
            }
            .padding(24)
            .navigationTitle("Pin")
            .sheet(isPresented: $showingFolderPicker) {
                FolderPicker { url in
                    recorder.selectDestination(url)
                }
            }
        }
    }
}
