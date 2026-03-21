import SwiftUI

enum NoteColor: String, CaseIterable, Codable {
    case yellow
    case green
    case blue
    case purple
    case pink
    case orange
    case gray

    // MARK: - Light mode

    var background: Color {
        switch self {
        case .yellow: Color(hex: 0xFFF9B1)
        case .green:  Color(hex: 0xC6EFB6)
        case .blue:   Color(hex: 0xB8D4E8)
        case .purple: Color(hex: 0xD5C4E0)
        case .pink:   Color(hex: 0xF5C4D0)
        case .orange: Color(hex: 0xFDDCB5)
        case .gray:   Color(hex: 0xD9D9D9)
        }
    }

    var toolbar: Color {
        switch self {
        case .yellow: Color(hex: 0xF2E685)
        case .green:  Color(hex: 0xA8D99A)
        case .blue:   Color(hex: 0x97BFD5)
        case .purple: Color(hex: 0xBDA8CC)
        case .pink:   Color(hex: 0xE8A8B8)
        case .orange: Color(hex: 0xF0C898)
        case .gray:   Color(hex: 0xC0C0C0)
        }
    }

    // MARK: - Dark mode (Microsoft Sticky Notes actual dark values)

    var darkBackground: Color {
        switch self {
        case .yellow: Color(hex: 0x7B7533)
        case .green:  Color(hex: 0x3D6B3D)
        case .blue:   Color(hex: 0x3B5E78)
        case .purple: Color(hex: 0x5B4670)
        case .pink:   Color(hex: 0x7B4058)
        case .orange: Color(hex: 0x8B6535)
        case .gray:   Color(hex: 0x555555)
        }
    }

    var darkToolbar: Color {
        switch self {
        case .yellow: Color(hex: 0x6B6528)
        case .green:  Color(hex: 0x335C33)
        case .blue:   Color(hex: 0x314F65)
        case .purple: Color(hex: 0x4D3A5E)
        case .pink:   Color(hex: 0x6B354B)
        case .orange: Color(hex: 0x78572B)
        case .gray:   Color(hex: 0x474747)
        }
    }

    var displayName: String {
        rawValue.capitalized
    }

    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkBackground : background
    }

    func toolbarColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkToolbar : toolbar
    }

    var listCardColor: Color {
        background.opacity(0.85)
    }
}
