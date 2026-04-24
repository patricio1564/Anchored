// ────────────────────────────────────────────────────────────────────────────
// StreakManager.swift
//
// Tracks the user's daily check-in streak, total XP, and last-activity
// date. Backed by the SwiftData `UserStreak` model.
//
// ─────────────────────── WHY @Observable + MIRRORED STATE ───────────────────
//
// The obvious design — expose `var streakRecord: UserStreak` as a computed
// property and let callers read `manager.streakRecord.currentStreak` —
// doesn't work with @Observable.
//
// @Observable tracks reads and writes to stored properties on THIS object.
// When you mutate a property on a SwiftData @Model instance you OWN but
// don't expose directly, the macro has no way to know a re-render is
// needed. SwiftUI views reading `manager.streakRecord.currentStreak`
// would go stale after every mutation.
//
// The fix: mirror the important state onto stored properties on the
// manager itself. Mutations go through `persist()`, which updates both
// the SwiftData record AND the mirrored properties in one place. Views
// observe the mirrored properties and get proper update notifications.
//
// The SwiftData record remains the source of truth on disk; the
// manager's properties are a cached read-through.
// ────────────────────────────────────────────────────────────────────────────

import Foundation
import SwiftData

@Observable
@MainActor
final class StreakManager {

    // MARK: - Mirrored state (observed by views)
    //
    // These mirror the SwiftData record. Views read these directly.
    // They are private(set) so only this class can mutate them.

    private(set) var currentStreak: Int = 0
    private(set) var longestStreak: Int = 0
    private(set) var totalXP: Int = 0
    private(set) var lastCheckInDate: Date? = nil

    // MARK: - Dependencies

    /// The SwiftData context used for persistence. Injected at init so
    /// previews can pass a preview container and tests can pass an
    /// in-memory one.
    private let modelContext: ModelContext

    /// The user ID that owns this streak record. Kept for future CloudKit.
    private let userId: String

    /// The calendar used for day-boundary math. Defaults to the user's
    /// current calendar so "yesterday" behaves how they'd expect across
    /// time zones.
    private let calendar: Calendar

    // MARK: - Init

    init(
        modelContext: ModelContext,
        userId: String,
        calendar: Calendar = .current
    ) {
        self.modelContext = modelContext
        self.userId = userId
        self.calendar = calendar
        // Seed the mirrored state from disk.
        reload()
    }

    // MARK: - Public API

    /// Compute the user's level from total XP. 100 XP per level.
    var level: Int {
        max(1, (totalXP / 100) + 1)
    }

    /// XP into the current level (0..<100).
    var xpInCurrentLevel: Int {
        totalXP % 100
    }

    /// XP required to complete the current level.
    var xpForCurrentLevel: Int { 100 }

    /// Human-readable title from Base44's getLevelTitle.
    var levelTitle: String {
        switch level {
        case ...2:    return "Seeker"
        case 3...5:   return "Disciple"
        case 6...10:  return "Scholar"
        case 11...15: return "Teacher"
        case 16...20: return "Elder"
        default:      return "Shepherd"
        }
    }

    /// Did the user already check in today? Useful for suppressing the
    /// "+streak" toast on repeat visits.
    var hasCheckedInToday: Bool {
        guard let last = lastCheckInDate else { return false }
        return calendar.isDateInToday(last)
    }

    // MARK: - Mutations

    /// Record a user activity that counts toward their streak (opening
    /// the Daily Verse, completing a lesson, writing a note). Handles
    /// the same-day / consecutive-day / broken-streak cases.
    ///
    /// Returns the streak *after* the check-in, so callers can celebrate
    /// milestones.
    @discardableResult
    func checkIn(on date: Date = Date()) -> Int {
        let record = fetchOrCreateRecord()
        let today = calendar.startOfDay(for: date)

        if let last = record.lastCheckInDate {
            let lastDay = calendar.startOfDay(for: last)
            let daysApart = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            switch daysApart {
            case 0:
                // Already checked in today — nothing to do.
                return record.currentStreak
            case 1:
                // Consecutive day: increment.
                record.currentStreak += 1
            default:
                // Gap (2+ days). Streak resets to 1.
                record.currentStreak = 1
            }
        } else {
            // First-ever check-in.
            record.currentStreak = 1
        }

        // New high-water mark?
        if record.currentStreak > record.longestStreak {
            record.longestStreak = record.currentStreak
        }
        record.lastCheckInDate = date

        persist(record)
        return record.currentStreak
    }

    /// Award XP for an activity. Does not check in — callers can combine
    /// `awardXP(..)` and `checkIn()` as appropriate for the action.
    func awardXP(_ amount: Int) {
        guard amount > 0 else { return }
        let record = fetchOrCreateRecord()
        record.totalXP += amount
        persist(record)
    }

    /// Destructive reset for the Profile → "Reset progress" affordance.
    /// Leaves the record row in place with zeroed fields.
    func reset() {
        let record = fetchOrCreateRecord()
        record.currentStreak = 0
        record.longestStreak = 0
        record.totalXP = 0
        record.lastCheckInDate = nil
        persist(record)
    }

    // MARK: - Private

    /// Pull the record from disk and mirror its fields onto self.
    private func reload() {
        let record = fetchOrCreateRecord()
        mirror(from: record)
    }

    /// Fetch the UserStreak for this userId, or create one if none exists.
    private func fetchOrCreateRecord() -> UserStreak {
        let capturedUserId = userId
        let descriptor = FetchDescriptor<UserStreak>(
            predicate: #Predicate<UserStreak> { $0.userId == capturedUserId }
        )
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                return existing
            }
        } catch {
            // Fetch shouldn't fail in practice; if it does, we still want
            // a record to return rather than crash. Fall through to create.
            assertionFailure("UserStreak fetch failed: \(error)")
        }
        let fresh = UserStreak(userId: userId)
        modelContext.insert(fresh)
        // Attempt to flush so subsequent fetches see it.
        try? modelContext.save()
        return fresh
    }

    /// Save the record and update mirrored state in one step. All
    /// mutation paths funnel through here so the view state can never
    /// drift from disk state.
    private func persist(_ record: UserStreak) {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("UserStreak save failed: \(error)")
        }
        mirror(from: record)
    }

    /// Copy the fields we expose onto our own stored properties. Writing
    /// to them triggers @Observable's change notifications, which is
    /// what the whole dance is for.
    private func mirror(from record: UserStreak) {
        self.currentStreak = record.currentStreak
        self.longestStreak = record.longestStreak
        self.totalXP = record.totalXP
        self.lastCheckInDate = record.lastCheckInDate
    }
}
