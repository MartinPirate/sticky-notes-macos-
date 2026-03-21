import SwiftUI

struct FormattingBar: View {
    let onBold: () -> Void
    let onItalic: () -> Void
    let onUnderline: () -> Void
    let onStrikethrough: () -> Void
    let onBulletList: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            formatButton(icon: "bold", tooltip: "Bold (⌘B)", action: onBold)
            formatButton(icon: "italic", tooltip: "Italic (⌘I)", action: onItalic)
            formatButton(icon: "underline", tooltip: "Underline (⌘U)", action: onUnderline)
            formatButton(icon: "strikethrough", tooltip: "Strikethrough", action: onStrikethrough)

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)

            formatButton(icon: "list.bullet", tooltip: "Bullet List", action: onBulletList)
        }
    }

    private func formatButton(icon: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 26, height: 26)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}
