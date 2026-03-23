import SwiftUI
import SwiftData

final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Keep app alive when the notes list window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Re-open the notes list when clicking the dock icon with no windows visible
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Re-show any existing list window, or SwiftUI will create a new one
            for window in sender.windows where window.title == "Sticky Notes" {
                window.makeKeyAndOrderFront(nil)
                return false
            }
        }
        return true
    }
}

@main
struct StickyNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var windowManager = WindowManager()
    @Environment(\.openWindow) private var openWindow

    let sharedContainer: ModelContainer = {
        let schema = Schema([StickyNote.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            NSLog("ModelContainer failed, resetting store: \(error)")
            let storeURL = config.url
            for ext in ["", ".wal", ".shm"] {
                let url = ext.isEmpty ? storeURL : storeURL.appendingPathExtension(ext)
                try? FileManager.default.removeItem(at: url)
            }
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Failed to create ModelContainer after reset: \(error)")
            }
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
