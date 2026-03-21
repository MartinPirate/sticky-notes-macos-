import SwiftUI

struct FormattingBar: View {
    let onBold: () -> Void
    let onItalic: () -> Void
    let onUnderline: () -> Void
    let onStrikethrough: () -> Void
    let onBulletList: () -> Void
    let onTodoList: () -> Void
    let onHiddenText: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            formatButton(icon: "bold", tooltip: "Bold (⌘B)", action: onBold)
            formatButton(icon: "italic", tooltip: "Italic (⌘I)", action: onItalic)
            formatButton(icon: "underline", tooltip: "Underline (⌘U)", action: onUnderline)
            formatButton(icon: "strikethrough", tooltip: "Strikethrough", action: onStrikethrough)

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 3)

            formatButton(icon: "list.bullet", tooltip: "Bullet List", action: onBulletList)
            formatButton(icon: "checklist", tooltip: "Todo List", action: onTodoList)

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 3)

            formatButton(icon: "eye.slash", tooltip: "Hide/Reveal Text", action: onHiddenText)
        }
    }

    private func formatButton(icon: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}
