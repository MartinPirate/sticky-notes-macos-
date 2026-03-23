import SwiftUI
import SwiftData

@MainActor
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
        findWindow(for: id)?.makeKeyAndOrderFront(nil)
    }

    func closeWindow(for id: UUID) {
        findWindow(for: id)?.close()
        markClosed(id)
    }

    func windowFrame(for id: UUID) -> NSRect? {
        findWindow(for: id)?.frame
    }

    private func findWindow(for id: UUID) -> NSWindow? {
        let windows = NSApplication.shared.windows
        return windows.first { $0.identifier?.rawValue == id.uuidString }
    }
}
