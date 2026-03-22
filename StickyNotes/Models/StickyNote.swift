import AppKit
import SwiftData

@Model
final class StickyNote {
    var id: UUID
    var plainTextContent: String
    var attributedContentData: Data?
    var colorRawValue: String
    var windowX: Double
    var windowY: Double
    var windowWidth: Double
    var windowHeight: Double
    var createdAt: Date
    var modifiedAt: Date
    var isOpen: Bool

    /// Audio recordings attached to this note (stored as m4a data)
    @Attribute(.externalStorage)
    var audioRecordings: [Data]

    var noteColor: NoteColor {
        get { NoteColor(rawValue: colorRawValue) ?? .yellow }
        set { colorRawValue = newValue.rawValue }
    }

    var title: String {
        let firstLine = plainTextContent.components(separatedBy: .newlines).first ?? ""
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "New Note" : String(trimmed.prefix(100))
    }

    var preview: String {
        let lines = plainTextContent.components(separatedBy: .newlines)
        let remaining = lines.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return String(remaining.prefix(200))
    }

    init(
        color: NoteColor = .yellow,
        content: String = ""
    ) {
        // Random position within the main screen bounds
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let width: Double = 300
        let height: Double = 350
        let maxX = max(screen.origin.x, screen.origin.x + screen.width - width - 40)
        let maxY = max(screen.origin.y, screen.origin.y + screen.height - height - 40)
        let randX = Double.random(in: (screen.origin.x + 40)...maxX)
        let randY = Double.random(in: (screen.origin.y + 40)...maxY)

        self.id = UUID()
        self.plainTextContent = content
        self.attributedContentData = nil
        self.colorRawValue = color.rawValue
        self.windowX = randX
        self.windowY = randY
        self.windowWidth = width
        self.windowHeight = height
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isOpen = false
        self.audioRecordings = []
    }
}
