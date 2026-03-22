import SwiftUI

struct NoteToolbarView: View {
    let note: StickyNote
    let proxy: TextEditorProxy
    let audioRecorder: AudioRecorder
    let speechRecognizer: SpeechRecognizer
    let onDelete: () -> Void
    let onAudioSaved: (Data) -> Void
    let onStartDictation: () -> Void
    let onStopDictation: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            FormattingBar(
                onBold: { proxy.toggleBold() },
                onItalic: { proxy.toggleItalic() },
                onUnderline: { proxy.toggleUnderline() },
                onStrikethrough: { proxy.toggleStrikethrough() },
                onBulletList: { proxy.toggleBulletList() },
                onTodoList: { proxy.toggleTodoList() },
                onHiddenText: { proxy.toggleHiddenText() }
            )

            Spacer()

            // Active recording indicator
            if audioRecorder.isRecording {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 6, height: 6)
                    Text(formatDuration(audioRecorder.recordingDuration))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.red)
                    Button {
                        if let data = audioRecorder.stopRecording() {
                            onAudioSaved(data)
                        }
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            // Active dictation indicator
            else if speechRecognizer.isListening {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 11))
                        .foregroundStyle(.blue)
                        .symbolEffect(.variableColor.iterative)
                    Text("Listening...")
                        .font(.system(size: 10))
                        .foregroundStyle(.blue)
                    Button {
                        onStopDictation()
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            else {
                // Audio input menu with two options
                Menu {
                    Button {
                        onStartDictation()
                    } label: {
                        Label("Dictate (Speech to Text)", systemImage: "text.bubble")
                    }

                    Button {
                        audioRecorder.startRecording()
                    } label: {
                        Label("Record Audio Clip", systemImage: "waveform.circle")
                    }
                } label: {
                    Image(systemName: "mic")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 26, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .menuIndicator(.hidden)
                .help("Audio Input")
            }

            // "..." menu
            Menu {
                Section {
                    ForEach(NoteColor.allCases, id: \.self) { color in
                        Button {
                            note.noteColor = color
                            note.modifiedAt = Date()
                        } label: {
                            HStack {
                                Image(systemName: note.noteColor == color ? "checkmark.circle.fill" : "circle.fill")
                                Text(color.displayName)
                            }
                        }
                    }
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Note", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(note.noteColor.toolbarColor(for: colorScheme))
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
