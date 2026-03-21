import SwiftUI

struct NoteToolbarView: View {
    let note: StickyNote
    let proxy: TextEditorProxy
    let audioRecorder: AudioRecorder
    let onDelete: () -> Void
    let onAudioSaved: (Data) -> Void
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

            // Audio record button
            Button {
                if audioRecorder.isRecording {
                    if let data = audioRecorder.stopRecording() {
                        onAudioSaved(data)
                    }
                } else {
                    audioRecorder.startRecording()
                }
            } label: {
                Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(audioRecorder.isRecording ? .red : .primary)
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(audioRecorder.isRecording ? "Stop Recording" : "Record Audio")

            if audioRecorder.isRecording {
                Text(formatDuration(audioRecorder.recordingDuration))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.red)
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
