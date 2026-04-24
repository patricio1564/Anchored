// ────────────────────────────────────────────────────────────────────────────
// Achievements.swift
//
// The 8 badges from Base44, rewritten as a pure-function unlock check
// over an AchievementSnapshot (progress + streak). Pure functions mean
// the Achievements view can recompute on every render with no caching
// concerns, and tests can assert outcomes deterministically.
//
// The snapshot is built at the call site by reading SwiftData models.
// This file has zero knowledge of SwiftData — all inputs are plain
// values.
// ────────────────────────────────────────────────────────────────────────────

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Snapshot
// ─────────────────────────────────────────────────────────────────────────────

/// Read-only snapshot of everything an achievement check needs.
///
/// Built from live SwiftData at the view layer:
/// ```
/// let snapshot = AchievementSnapshot(
///     completedLessons: completedLessonProgressArray,
///     longestStreak: streakManager.longestStreak,
///     totalXP: streakManager.totalXP
/// )
/// ```
struct AchievementSnapshot: Sendable {
    /// One entry per completed lesson. `score` is 0...100, `topicID` is
    /// the Topic.id the lesson belongs to.
    let completedLessons: [LessonResult]
    let longestStreak: Int
    let totalXP: Int

    struct LessonResult: Hashable, Sendable {
        let lessonID: String
        let topicID: String
        /// 0...100. 100 means a perfect quiz run.
        let score: Int
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Achievement definitions
// ─────────────────────────────────────────────────────────────────────────────

/// Visual + metadata for each badge. `isUnlocked` is computed on demand.
struct Achievement: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    /// SF Symbol name. The Base44 version used Lucide icons; we pick close SF Symbols.
    let sfSymbol: String
    /// Gradient for the unlocked badge. Uses TopicGradient so we get theming for free.
    let gradient: TopicGradient
    /// Pure check: does this snapshot unlock the achievement?
    let isUnlocked: @Sendable (AchievementSnapshot) -> Bool

    // Identifiable/Hashable work through `id`. The closure isn't hashable so
    // we override both manually.
    static func == (lhs: Achievement, rhs: Achievement) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum Achievements {

    /// The 8 built-in badges in display order.
    static let all: [Achievement] = [
        Achievement(
            id: "first_lesson",
            title: "First Steps",
            description: "Complete your first lesson",
            sfSymbol: "book.fill",
            gradient: .green400ToTeal500,
            isUnlocked: { snap in snap.completedLessons.count >= 1 }
        ),
        Achievement(
            id: "streak_3",
            title: "Faithful",
            description: "Reach a 3-day streak",
            sfSymbol: "flame.fill",
            gradient: .orange400ToRed500,
            isUnlocked: { snap in snap.longestStreak >= 3 }
        ),
        Achievement(
            id: "streak_7",
            title: "Devoted",
            description: "Reach a 7-day streak",
            sfSymbol: "flame.fill",
            gradient: .orange500ToRed500,
            isUnlocked: { snap in snap.longestStreak >= 7 }
        ),
        Achievement(
            id: "lessons_5",
            title: "Scholar",
            description: "Complete 5 lessons",
            sfSymbol: "books.vertical.fill",
            gradient: .indigo400ToBlue500,
            isUnlocked: { snap in snap.completedLessons.count >= 5 }
        ),
        Achievement(
            id: "lessons_10",
            title: "Wise One",
            description: "Complete 10 lessons",
            sfSymbol: "crown.fill",
            gradient: .violet400ToBlue500,
            isUnlocked: { snap in snap.completedLessons.count >= 10 }
        ),
        Achievement(
            id: "perfect",
            title: "Perfect Score",
            description: "Get 100% on a lesson",
            sfSymbol: "target",
            gradient: .amber400ToYellow500,
            isUnlocked: { snap in snap.completedLessons.contains { $0.score == 100 } }
        ),
        Achievement(
            id: "xp_500",
            title: "Dedicated",
            description: "Earn 500 XP total",
            sfSymbol: "star.fill",
            gradient: .yellow500ToAmber600,
            isUnlocked: { snap in snap.totalXP >= 500 }
        ),
        Achievement(
            id: "all_topics",
            title: "Well Rounded",
            description: "Complete a lesson in every topic",
            sfSymbol: "trophy.fill",
            gradient: .pink400ToRose500,
            isUnlocked: { snap in
                let completedTopicIDs = Set(snap.completedLessons.map(\.topicID))
                let allTopicIDs = Set(TopicsCatalog.all.map(\.id))
                return allTopicIDs.isSubset(of: completedTopicIDs)
            }
        )
    ]

    /// Filter the `all` list to only unlocked achievements for a given snapshot.
    static func earned(from snapshot: AchievementSnapshot) -> [Achievement] {
        all.filter { $0.isUnlocked(snapshot) }
    }

    /// Count of unlocked achievements.
    static func earnedCount(from snapshot: AchievementSnapshot) -> Int {
        all.reduce(0) { $0 + ($1.isUnlocked(snapshot) ? 1 : 0) }
    }
}
