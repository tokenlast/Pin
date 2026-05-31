import AVFoundation
import Foundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var statusText = "Choose your Pens folder to start."
    @Published private(set) var destinationName = "No folder selected"
    @Published private(set) var destinationDetail = "Pick your iCloud Drive Pens folder once."
    @Published private(set) var lastSavedFile: String?

    private let destinationStore = DestinationFolderStore()
    private var audioRecorder: AVAudioRecorder?
    private var temporaryRecordingURL: URL?
    private var activeRecordingName: String?

    override init() {
        super.init()
        refreshDestination()
    }

    var hasDestination: Bool {
        destinationStore.resolveDestination() != nil
    }

    var canRecord: Bool {
        hasDestination || isRecording
    }

    func selectDestination(_ url: URL) {
        do {
            try destinationStore.saveDestination(url)
            refreshDestination()
            statusText = "Ready to record into \(url.lastPathComponent)."
        } catch {
            statusText = "Could not save that folder. \(error.localizedDescription)"
        }
    }

    func toggleFromWidget() {
        toggleRecording()
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        guard hasDestination else {
            statusText = "Choose your Pens folder first."
            return
        }

        requestMicrophonePermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.statusText = "Microphone access is required."
                return
            }

            do {
                try self.beginRecording()
            } catch {
                self.statusText = "Could not start recording. \(error.localizedDescription)"
            }
        }
    }

    private func stopRecording() {
        guard let recorder = audioRecorder, let sourceURL = temporaryRecordingURL else {
            isRecording = false
            statusText = "No active recording."
            return
        }

        recorder.stop()
        audioRecorder = nil
        temporaryRecordingURL = nil
        isRecording = false

        do {
            let savedURL = try moveRecordingToDestination(from: sourceURL)
            lastSavedFile = savedURL.lastPathComponent
            statusText = "Saved to \(destinationName)."
        } catch {
            statusText = "Could not save recording. \(error.localizedDescription)"
        }

        try? AVAudioSession.sharedInstance().setActive(false)
    }

    private func beginRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let fileName = makeRecordingName()
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: temporaryURL, settings: settings)
        recorder.prepareToRecord()
        recorder.record()

        audioRecorder = recorder
        temporaryRecordingURL = temporaryURL
        activeRecordingName = fileName
        isRecording = true
        statusText = "Tap again to stop."
    }

    private func moveRecordingToDestination(from sourceURL: URL) throws -> URL {
        guard let destinationFolder = destinationStore.resolveDestination() else {
            throw RecorderError.missingDestination
        }

        let accessed = destinationFolder.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                destinationFolder.stopAccessingSecurityScopedResource()
            }
        }

        let fileName = activeRecordingName ?? sourceURL.lastPathComponent
        let destinationURL = destinationFolder.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        activeRecordingName = nil
        return destinationURL
    }

    private func requestMicrophonePermission(_ completion: @escaping (Bool) -> Void) {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }

    private func refreshDestination() {
        if let url = destinationStore.resolveDestination() {
            destinationName = url.lastPathComponent
            destinationDetail = url.path(percentEncoded: false)
            statusText = "Ready to record into \(url.lastPathComponent)."
        } else {
            destinationName = "No folder selected"
            destinationDetail = "Pick your iCloud Drive Pens folder once."
        }
    }

    private func makeRecordingName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return "Pens Recording \(formatter.string(from: Date())).m4a"
    }
}

private enum RecorderError: LocalizedError {
    case missingDestination

    var errorDescription: String? {
        switch self {
        case .missingDestination:
            return "Choose a destination folder first."
        }
    }
}
