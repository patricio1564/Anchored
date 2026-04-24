//
//  Prayer.swift
//  Anchored
//
//  A prayer journal entry. Supports status (active/answered/archived),
//  optional reminders, and an optional "answered note" for testimonies.
//  Ported from Base44's `Prayer` entity.
//

import Foundation
import SwiftData

enum PrayerStatus: String, Codable, CaseIterable {
    case active, answered, archived

    var displayName: String {
        switch self {
        case .active:   return "Active"
        case .answered: return "Answered"
        case .archived: return "Archived"
        }
    }
}

@Model
final class Prayer {
    /// Short title, required.
    var title: String

    /// The body of the prayer, required.
    var content: String

    /// Optional verse reference (e.g. "John 3:16") the user is praying with.
    var linkedVerse: String?

    /// Privacy flag — always local-only for v1 (no sharing), but we keep the
    /// field so a future sharing feature doesn't require migration.
    var isPrivate: Bool

    /// Whether a daily reminder notification is scheduled for this prayer.
    var reminderEnabled: Bool

    /// Time-of-day for the reminder, stored as "HH:mm" (e.g. "07:30").
    var reminderTime: String?

    /// Raw status string. Use `statusValue` for the typed accessor.
    var statusRaw: String

    /// If the prayer has been answered, this is the user's note about how.
    var answeredNote: String?

    var createdAt: Date
    var updatedAt: Date

    var userId: String?

    init(
        title: String,
        content: String,
        linkedVerse: String? = nil,
        isPrivate: Bool = true,
        reminderEnabled: Bool = false,
        reminderTime: String? = nil,
        status: PrayerStatus = .active,
        answeredNote: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        userId: String? = nil
    ) {
        self.title = title
        self.content = content
        self.linkedVerse = linkedVerse
        self.isPrivate = isPrivate
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.statusRaw = status.rawValue
        self.answeredNote = answeredNote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }

    /// Typed accessor for the prayer's status.
    var status: PrayerStatus {
        get { PrayerStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }
}
