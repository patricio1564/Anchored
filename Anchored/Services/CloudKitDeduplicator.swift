//
//  CloudKitDeduplicator.swift
//  Anchored
//
//  UserSettings and UserStreak are singletons — one row per user. When two
//  devices both create a row before the initial CloudKit sync arrives, each
//  device ends up with two rows after sync settles. This runs on every
//  foreground transition (cheap, idempotent) and merges any duplicates.
//

import Foundation
import SwiftData

@MainActor
enum CloudKitDeduplicator {

    static func deduplicateIfNeeded(in context: ModelContext, userId: String?) {
        deduplicateUserSettings(in: context, userId: userId)
        deduplicateUserStreak(in: context)
    }

    // MARK: - UserSettings

    private static func deduplicateUserSettings(in context: ModelContext, userId: String?) {
        guard let rows = try? context.fetch(FetchDescriptor<UserSettings>()),
              rows.count > 1 else { return }

        // Prefer the row matching the signed-in user; fall back to the one
        // with an active reminder time (indicating it was actively configured).
        let canonical = rows.first { $0.userId == userId }
            ?? rows.first { $0.dailyReminderTime != nil }
            ?? rows[0]

        for row in rows where row !== canonical {
            if canonical.displayName == nil     { canonical.displayName = row.displayName }
            if canonical.goals == nil           { canonical.goals = row.goals }
            if canonical.bibleExperience == nil { canonical.bibleExperience = row.bibleExperience }
            if canonical.userId == nil          { canonical.userId = row.userId }
            context.delete(row)
        }
        try? context.save()
    }

    // MARK: - UserStreak

    private static func deduplicateUserStreak(in context: ModelContext) {
        guard let rows = try? context.fetch(FetchDescriptor<UserStreak>()),
              rows.count > 1 else { return }

        // Keep the row with the most XP — never discard earned progress.
        let canonical = rows.max(by: { $0.totalXP < $1.totalXP }) ?? rows[0]

        for row in rows where row !== canonical {
            canonical.currentStreak = max(canonical.currentStreak, row.currentStreak)
            canonical.longestStreak = max(canonical.longestStreak, row.longestStreak)
            canonical.totalXP       = max(canonical.totalXP, row.totalXP)
            if let d = row.lastCheckInDate {
                canonical.lastCheckInDate = canonical.lastCheckInDate.map { max($0, d) } ?? d
            }
            context.delete(row)
        }
        try? context.save()
    }
}
