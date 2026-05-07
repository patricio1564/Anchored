//
//  AppearanceManager.swift
//  Anchored
//
//  Manages the user's light/dark/system appearance preference.
//  Stored in UserDefaults and applied via .preferredColorScheme()
//  on the root view.
//

import SwiftUI

@Observable
@MainActor
final class AppearanceManager {

    enum Mode: String, CaseIterable {
        case system, light, dark

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }

    private static let key = "appearanceMode"

    var mode: Mode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Self.key) }
    }

    /// Returns nil for system (no override), or the explicit scheme.
    var colorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key) ?? "system"
        self.mode = Mode(rawValue: saved) ?? .system
    }
}
