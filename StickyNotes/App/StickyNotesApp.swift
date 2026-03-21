import SwiftUI
import SwiftData

@main
struct StickyNotesApp: App {
    @State private var windowManager = WindowManager()
    @Environment(\.openWindow) private var openWindow

    /// Single shared container so list + note windows share the same data
    let sharedContainer: ModelContainer = {
        do {
            return try ModelContainer(for: StickyNote.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("Sticky Notes") {
            NotesListView()
                .environment(windowManager)
                .onReceive(NotificationCenter.default.publisher(for: .openNoteWindow)) { notification in
                    if let noteID = notification.userInfo?["noteID"] as? UUID {
                        openWindow(value: noteID)
                    }
                }
        }
        .modelContainer(sharedContainer)
        .defaultSize(width: 320, height: 500)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") {
                    NotificationCenter.default.post(name: .createNewNote, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandMenu("Format") {
                Button("Bold") {
                    NotificationCenter.default.post(name: .formatBold, object: nil)
                }
                .keyboardShortcut("b", modifiers: .command)

                Button("Italic") {
                    NotificationCenter.default.post(name: .formatItalic, object: nil)
                }
                .keyboardShortcut("i", modifiers: .command)

                Button("Underline") {
                    NotificationCenter.default.post(name: .formatUnderline, object: nil)
                }
                .keyboardShortcut("u", modifiers: .command)
            }
        }

        WindowGroup("Note", for: UUID.self) { $noteID in
            if let noteID {
                NoteWindowView(noteID: noteID)
                    .environment(windowManager)
            }
        }
        .modelContainer(sharedContainer)
        .defaultSize(width: 300, height: 350)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let createNewNote = Notification.Name("createNewNote")
    static let formatBold = Notification.Name("formatBold")
    static let formatItalic = Notification.Name("formatItalic")
    static let formatUnderline = Notification.Name("formatUnderline")
}
