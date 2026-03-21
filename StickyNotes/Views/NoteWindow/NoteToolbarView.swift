import SwiftUI

struct NoteToolbarView: View {
    let note: StickyNote
    let proxy: TextEditorProxy
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            FormattingBar(
                onBold: { proxy.toggleBold() },
                onItalic: { proxy.toggleItalic() },
                onUnderline: { proxy.toggleUnderline() },
                onStrikethrough: { proxy.toggleStrikethrough() },
                onBulletList: { proxy.toggleBulletList() }
            )

            Spacer()

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
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(note.noteColor.toolbarColor(for: colorScheme))
    }
}
