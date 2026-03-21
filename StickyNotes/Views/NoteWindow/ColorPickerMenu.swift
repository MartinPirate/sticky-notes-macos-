import SwiftUI

struct ColorPickerMenu: View {
    let currentColor: NoteColor
    let onColorSelected: (NoteColor) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(NoteColor.allCases, id: \.self) { color in
                Button {
                    onColorSelected(color)
                } label: {
                    ZStack {
                        Circle()
                            .fill(color.background)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )

                        if color == currentColor {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.primary.opacity(0.7))
                        }
                    }
                }
                .buttonStyle(.plain)
                .help(color.displayName)
            }
        }
    }
}
