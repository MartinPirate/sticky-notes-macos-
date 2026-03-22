import SwiftUI
import SwiftData

struct NoteWindowView: View {
    let noteID: UUID
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(WindowManager.self) private var windowManager
    @State private var note: StickyNote?
    @State private var attributedText = NSAttributedString()
    @State private var plainText = ""
    @State private var editorProxy = TextEditorProxy()
    @State private var audioRecorder = AudioRecorder()
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var showDeleteConfirmation = false
    /// Tracks where dictation text was inserted so partial results replace in-place
    @State private var dictationAnchor: Int?
    @State private var dictationLength: Int = 0
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete = true

    var body: some View {
        Group {
            if let note {
                VStack(spacing: 0) {
                    NoteToolbarView(
                        note: note,
                        proxy: editorProxy,
                        audioRecorder: audioRecorder,
                        speechRecognizer: speechRecognizer,
                        onDelete: { requestDelete() },
                        onAudioSaved: { data in
                            note.audioRecordings.append(data)
                            note.modifiedAt = Date()
                            try? modelContext.save()
                        },
                        onStartDictation: { startLiveDictation() },
                        onStopDictation: { stopLiveDictation() }
                    )

                    NoteTextEditor(
                        attributedText: $attributedText,
                        plainText: $plainText,
                        backgroundColor: NSColor(note.noteColor.backgroundColor(for: colorScheme)),
                        proxy: editorProxy,
                        onTextChange: { saveContent() }
                    )

                    AudioClipView(
                        recordings: note.audioRecordings,
                        audioRecorder: audioRecorder,
                        onDelete: { index in
                            note.audioRecordings.remove(at: index)
                            note.modifiedAt = Date()
                            try? modelContext.save()
                        }
                    )
                }
                .background(
                    WindowAccessor(
                        noteID: noteID,
                        noteColor: note.noteColor,
                        windowFrame: NSRect(
                            x: note.windowX,
                            y: note.windowY,
                            width: note.windowWidth,
                            height: note.windowHeight
                        ),
                        onWindowFound: { window in
                            observeWindowChanges(window)
                        },
                        onClose: {
                            audioRecorder.stopPlayback()
                            windowManager.markClosed(noteID)
                            note.isOpen = false
                            saveWindowPosition()
                        }
                    )
                )
            } else {
                Text("Note not found")
                    .frame(width: 300, height: 200)
            }
        }
        .alert("Delete Note?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteNote() }
        } message: {
            Text("This note will be permanently deleted.")
        }
        .onAppear { loadNote() }
    }

    private func loadNote() {
        let id = noteID
        let descriptor = FetchDescriptor<StickyNote>(
            predicate: #Predicate { $0.id == id }
        )
        if let found = try? modelContext.fetch(descriptor).first {
            self.note = found
            if let data = found.attributedContentData,
               let restored = try? NSKeyedUnarchiver.unarchivedObject(
                   ofClass: NSAttributedString.self,
                   from: data
               ) {
                self.attributedText = restored
            }
            self.plainText = found.plainTextContent
            windowManager.markOpened(noteID)
        }
    }

    private func saveContent() {
        guard let note else { return }
        note.plainTextContent = plainText
        note.attributedContentData = try? NSKeyedArchiver.archivedData(
            withRootObject: attributedText,
            requiringSecureCoding: false
        )
        note.modifiedAt = Date()
        try? modelContext.save()
    }

    private func saveWindowPosition() {
        guard let note else { return }
        windowManager.saveWindowFrame(noteID, note: note)
        try? modelContext.save()
    }

    private func observeWindowChanges(_ window: NSWindow) {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { _ in
            saveWindowPositionFromWindow(window)
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: window,
            queue: .main
        ) { _ in
            saveWindowPositionFromWindow(window)
        }
    }

    private func saveWindowPositionFromWindow(_ window: NSWindow) {
        guard let note else { return }
        let frame = window.frame
        note.windowX = Double(frame.origin.x)
        note.windowY = Double(frame.origin.y)
        note.windowWidth = Double(frame.size.width)
        note.windowHeight = Double(frame.size.height)
    }

    private func startLiveDictation() {
        guard let textView = editorProxy.textView else { return }

        // Record anchor point at current cursor
        let cursor = textView.selectedRange()
        var anchor = cursor.location

        // Add a space before if needed
        if anchor > 0 {
            let prevChar = (textView.string as NSString).substring(with: NSRange(location: anchor - 1, length: 1))
            if prevChar != " " && prevChar != "\n" {
                textView.insertText(" ", replacementRange: NSRange(location: anchor, length: 0))
                anchor += 1
            }
        }

        dictationAnchor = anchor
        dictationLength = 0

        // Set up live streaming callback
        speechRecognizer.onPartialResult = { [self] partialText in
            guard let textView = editorProxy.textView,
                  let anchor = dictationAnchor else { return }

            // Replace the previous partial text with the new one
            let replaceRange = NSRange(location: anchor, length: dictationLength)
            textView.insertText(partialText, replacementRange: replaceRange)
            dictationLength = (partialText as NSString).length

            // Move cursor to end of dictated text
            textView.setSelectedRange(NSRange(location: anchor + dictationLength, length: 0))
        }

        speechRecognizer.requestAuthorization { authorized in
            if authorized {
                speechRecognizer.startListening()
            }
        }
    }

    private func stopLiveDictation() {
        speechRecognizer.stopListening()
        speechRecognizer.onPartialResult = nil
        dictationAnchor = nil
        dictationLength = 0
        saveContent()
    }

    private func requestDelete() {
        if confirmBeforeDelete {
            showDeleteConfirmation = true
        } else {
            deleteNote()
        }
    }

    private func deleteNote() {
        guard let note else { return }
        audioRecorder.stopPlayback()
        windowManager.markClosed(noteID)
        modelContext.delete(note)
        try? modelContext.save()
        if let window = NSApplication.shared.windows.first(where: {
            $0.identifier?.rawValue == noteID.uuidString
        }) {
            window.close()
        }
    }
}
