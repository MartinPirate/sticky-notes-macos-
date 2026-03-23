import SwiftUI

enum NoteColor: String, CaseIterable, Codable {
    case yellow, green, blue, purple, pink, orange, gray

    // MARK: - Color Data (single source of truth per color)

    private var colorSet: (light: UInt, dark: UInt, toolbarLight: UInt, toolbarDark: UInt) {
        switch self {
        case .yellow: (0xFFF9B1, 0x7B7533, 0xF2E685, 0x6B6528)
        case .green:  (0xC6EFB6, 0x3D6B3D, 0xA8D99A, 0x335C33)
        case .blue:   (0xB8D4E8, 0x3B5E78, 0x97BFD5, 0x314F65)
        case .purple: (0xD5C4E0, 0x5B4670, 0xBDA8CC, 0x4D3A5E)
        case .pink:   (0xF5C4D0, 0x7B4058, 0xE8A8B8, 0x6B354B)
        case .orange: (0xFDDCB5, 0x8B6535, 0xF0C898, 0x78572B)
        case .gray:   (0xD9D9D9, 0x555555, 0xC0C0C0, 0x474747)
        }
    }

    var background: Color { Color(hex: colorSet.light) }
    var darkBackground: Color { Color(hex: colorSet.dark) }
    var toolbar: Color { Color(hex: colorSet.toolbarLight) }
    var darkToolbar: Color { Color(hex: colorSet.toolbarDark) }

    var displayName: String { rawValue.capitalized }

    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkBackground : background
    }

    func toolbarColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkToolbar : toolbar
    }

    func listCardColor(for colorScheme: ColorScheme) -> Color {
        backgroundColor(for: colorScheme).opacity(0.85)
    }
}
