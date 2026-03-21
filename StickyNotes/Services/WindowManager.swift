import SwiftUI
import SwiftData

@Observable
final class WindowManager {
    private(set) var openNoteIDs: Set<UUID> = []

    func markOpened(_ id: UUID) {
        openNoteIDs.insert(id)
    }

    func markClosed(_ id: UUID) {
        openNoteIDs.remove(id)
    }

    func isOpen(_ id: UUID) -> Bool {
        openNoteIDs.contains(id)
    }

    func bringToFront(_ id: UUID) {
        for window in NSApplication.shared.windows {
            if window.identifier?.rawValue == id.uuidString {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }

    func saveWindowFrame(_ id: UUID, note: StickyNote) {
        for window in NSApplication.shared.windows {
            if window.identifier?.rawValue == id.uuidString {
                let frame = window.frame
                note.windowX = Double(frame.origin.x)
                note.windowY = Double(frame.origin.y)
                note.windowWidth = Double(frame.size.width)
                note.windowHeight = Double(frame.size.height)
                return
            }
        }
    }
}
