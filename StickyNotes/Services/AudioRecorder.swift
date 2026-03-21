import AVFoundation
import AppKit

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

    private var tempDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    func startRecording() {
        let url = tempDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
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
                self?.recordingDuration = self?.audioRecorder?.currentTime ?? 0
            }
        } catch {
            NSLog("Failed to start recording: \(error)")
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
        return try? Data(contentsOf: url)
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
            NSLog("Failed to play audio: \(error)")
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
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playingIndex = nil
    }
}
