import SwiftUI

enum AnchoredColors {

    // MARK: - Background gradient (vertical, top → bottom)

    static let bg1 = Color(hex: "#FFF6EE")
    static let bg2 = Color(hex: "#F0E9F7")
    static let bg3 = Color(hex: "#E8EFF8")

    // MARK: - Surface

    static let paper = Color.white
    static let glass = Color.white.opacity(0.70)
    static let glassStrong = Color.white.opacity(0.85)

    // MARK: - Ink (text + structure)

    static let ink = Color(hex: "#1F2647")
    static let inkSoft = Color(hex: "#5C6388")
    static let inkMute = Color(hex: "#9BA0BB")

    // MARK: - Brand accents

    static let coral = Color(hex: "#E07A5F")
    static let coralSoft = Color(hex: "#F4C7B6")
    static let gold = Color(hex: "#E8B65C")
    static let blue = Color(hex: "#6E8EC7")
    static let blueSoft = Color(hex: "#C8D6EC")
    static let lilac = Color(hex: "#A48FC7")

    // MARK: - Lines

    static let line = Color(red: 31/255, green: 38/255, blue: 71/255).opacity(0.10)
    static let lineSoft = Color(red: 31/255, green: 38/255, blue: 71/255).opacity(0.06)

    // MARK: - Gradients

    static let gradientPrimary = LinearGradient(
        colors: [coral, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientCool = LinearGradient(
        colors: [lilac, blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [bg1, bg2, bg3],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - State

    static let success = Color(red: 34/255, green: 139/255, blue: 87/255)
    static let error = Color(red: 200/255, green: 62/255, blue: 62/255)
    static let streak = coral

    // MARK: - Legacy aliases

    static let parchment = bg1
    static let navy = ink
    static let amber = coral
    static let amberSoft = coralSoft
    static let muted = inkSoft
    static let border = line
    static let card = paper
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
