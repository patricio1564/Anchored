import SwiftUI

enum HighlightColor: String, CaseIterable, Identifiable {
    case yellow, green, blue, pink, purple

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .yellow: return Color(hex: "#FCD34D")
        case .green:  return Color(hex: "#6EE7B7")
        case .blue:   return Color(hex: "#93C5FD")
        case .pink:   return Color(hex: "#F9A8D4")
        case .purple: return Color(hex: "#C4B5FD")
        }
    }
}
