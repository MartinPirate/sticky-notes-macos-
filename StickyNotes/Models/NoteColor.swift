import SwiftUI

enum NoteColor: String, CaseIterable, Codable {
    case yellow
    case green
    case blue
    case purple
    case pink
    case orange
    case gray

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

    var darkBackground: Color {
        switch self {
        case .yellow: Color(hex: 0x4C4A17)
        case .green:  Color(hex: 0x1E3A1E)
        case .blue:   Color(hex: 0x1E2D3A)
        case .purple: Color(hex: 0x2D1E3A)
        case .pink:   Color(hex: 0x3A1E2D)
        case .orange: Color(hex: 0x3A2D1E)
        case .gray:   Color(hex: 0x2D2D2D)
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

    var darkToolbar: Color {
        switch self {
        case .yellow: Color(hex: 0x3D3B12)
        case .green:  Color(hex: 0x162E16)
        case .blue:   Color(hex: 0x16232E)
        case .purple: Color(hex: 0x23162E)
        case .pink:   Color(hex: 0x2E1623)
        case .orange: Color(hex: 0x2E2316)
        case .gray:   Color(hex: 0x232323)
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
