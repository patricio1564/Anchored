//
//  UserStreak.swift
//  Anchored
//
//  Tracks the user's gamification state: daily streak, XP total, and
//  last check-in date. There is exactly one UserStreak record per user
//  (treated as a singleton). Maps to Base44's `UserStreak` entity.
//
//  ───── Field names intentionally match StreakManager ─────
//  The Layer 2 StreakManager reads/writes `totalXP` (capital P) and
//  `lastCheckInDate` directly on this model. If you rename either,
//  rename them there too. Level and lifetime-lesson count are
//  intentionally *not* stored — StreakManager derives level from XP
//  (`level = totalXP / 100 + 1`), and lesson count is a LessonProgress
//  fetch-count, not a cached field.
//

import Foundation
import SwiftData

@Model
final class UserStreak {
    /// Current consecutive-day streak.
    var currentStreak: Int

    /// All-time longest streak — persisted separately so it doesn't reset.
    var longestStreak: Int

    /// Lifetime XP total. Never decreases (except via explicit reset).
    /// Capital P matches StreakManager.totalXP.
    var totalXP: Int

    /// Timestamp of the most recent check-in. Streak extends if the
    /// next check-in falls on the following calendar day, resets
    /// otherwise. `nil` means the user has never checked in.
    var lastCheckInDate: Date?

    /// Owner of this record. Single local user in v1; kept for a future
    /// CloudKit sync without a migration.
    var userId: String?

    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalXP: Int = 0,
        lastCheckInDate: Date? = nil,
        userId: String? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalXP = totalXP
        self.lastCheckInDate = lastCheckInDate
        self.userId = userId
    }
}
