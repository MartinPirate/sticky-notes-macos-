import SwiftUI

struct NoteCardView: View {
    let note: StickyNote
    let onOpen: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .foregroundStyle(.primary)

            if !note.preview.isEmpty {
                Text(note.preview)
                    .font(.system(size: 12))
                    .lineLimit(3)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Text(note.modifiedAt.noteListFormatted)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
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
