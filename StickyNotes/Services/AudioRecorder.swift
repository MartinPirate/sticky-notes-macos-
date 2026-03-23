import AVFoundation
import AppKit

@MainActor
@Observable
final class AudioRecorder: NSObject {
    var isRecording = false
    var isPlaying = false
    var playingIndex: Int?
    var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    private var timer: Timer?

    func startRecording() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        recordingURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.recordingDuration = self?.audioRecorder?.currentTime ?? 0
                }
            }
        } catch {
            NSLog("AudioRecorder: failed to start — \(error.localizedDescription)")
        }
    }

    func stopRecording() -> Data? {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        isRecording = false

        guard let url = recordingURL else { return nil }
        defer {
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
        }

        guard let data = try? Data(contentsOf: url) else {
            NSLog("AudioRecorder: failed to read recorded file")
            return nil
        }

        // Validate the data is playable audio
        guard (try? AVAudioPlayer(data: data)) != nil else {
            NSLog("AudioRecorder: recorded data is not valid audio")
            return nil
        }

        return data
    }

    func play(data: Data, index: Int) {
        stopPlayback()

        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            playingIndex = index
        } catch {
            NSLog("AudioRecorder: playback failed — \(error.localizedDescription)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playingIndex = nil
    }

    func durationOf(data: Data) -> TimeInterval? {
        guard let player = try? AVAudioPlayer(data: data) else { return nil }
        return player.duration
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            isRecording = false
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            playingIndex = nil
        }
    }
}
