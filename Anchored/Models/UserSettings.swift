//
//  UserSettings.swift
//  Anchored
//
//  User preferences that persist across launches. One record per user;
//  treated as a singleton. The translation field controls the default
//  bible-api.com query and the verse recommender output.
//

import Foundation
import SwiftData

/// Reading font size scale.
enum FontSizeScale: String, Codable, CaseIterable {
    case small, medium, large, xlarge

    var displayName: String {
        switch self {
        case .small:  return "Small"
        case .medium: return "Medium"
        case .large:  return "Large"
        case .xlarge: return "Extra Large"
        }
    }

    /// Multiplier applied to the base scripture font size.
    var multiplier: CGFloat {
        switch self {
        case .small:  return 0.9
        case .medium: return 1.0
        case .large:  return 1.15
        case .xlarge: return 1.3
        }
    }
}

@Model
final class UserSettings {
    /// Translation identifier — maps to bible-api.com query param.
    /// "asv" (American Standard Version) is the free default; WEB/KJV/BBE/Darby
    /// are gated behind premium.
    var preferredTranslation: String

    /// Font size scale for reading.
    var fontSizeRaw: String

    /// Master notification toggle.
    var notificationsEnabled: Bool

    /// Time-of-day for daily verse reminder ("HH:mm" format, or nil if off).
    var dailyReminderTime: String?

    /// Display name — captured from Sign in with Apple on first sign-in.
    var displayName: String?

    /// User email from Sign in with Apple. May be the relay address.
    var email: String?

    var userId: String?

    /// JSON-encoded [String] of onboarding goal selections (e.g. ["faith", "reading"]).
    var goals: String?

    /// Onboarding experience selection: "new" | "some" | "regular" | "lifelong".
    var bibleExperience: String?

    init(
        preferredTranslation: String = "asv",
        fontSize: FontSizeScale = .medium,
        notificationsEnabled: Bool = true,
        dailyReminderTime: String? = "08:00",
        displayName: String? = nil,
        email: String? = nil,
        userId: String? = nil
    ) {
        self.preferredTranslation = preferredTranslation
        self.fontSizeRaw = fontSize.rawValue
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.displayName = displayName
        self.email = email
        self.userId = userId
    }

    var fontSize: FontSizeScale {
        get { FontSizeScale(rawValue: fontSizeRaw) ?? .medium }
        set { fontSizeRaw = newValue.rawValue }
    }
}
