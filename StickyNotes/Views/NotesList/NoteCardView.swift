import SwiftUI

struct NoteCardView: View {
    let note: StickyNote
    let isCollapsed: Bool
    let onOpen: () -> Void
    let onDelete: () -> Void
    let onToggleCollapse: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: isCollapsed ? 0 : 6) {
            HStack {
                Text(note.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Spacer()

                if !note.audioRecordings.isEmpty {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }

                Text(note.modifiedAt.noteListFormatted)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            if !isCollapsed {
                if !note.preview.isEmpty {
                    Text(note.preview)
                        .font(.system(size: 12))
                        .lineLimit(3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isCollapsed ? 10 : 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(note.noteColor.backgroundColor(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .contextMenu {
            Button("Open Note") { onOpen() }
            Divider()
            Menu("Color") {
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
            Button("Delete", role: .destructive) { onDelete() }
        }
    }
}
