import Speech
import AVFoundation

@Observable
final class SpeechRecognizer {
    var isListening = false
    var transcript = ""
    var error: String?

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func startListening() {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = "Speech recognition not available"
            return
        }

        // Cancel any ongoing task
        stopListening()

        transcript = ""
        error = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if let error {
                DispatchQueue.main.async {
                    // Don't show error if we intentionally stopped
                    if self.isListening {
                        self.error = error.localizedDescription
                    }
                    self.stopListening()
                }
            }

            if result?.isFinal == true {
                DispatchQueue.main.async {
                    self.stopListening()
                }
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            self.error = "Could not start audio engine: \(error.localizedDescription)"
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
}
