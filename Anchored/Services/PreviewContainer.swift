//
//  PreviewContainer.swift
//  Anchored
//
//  Shared in-memory SwiftData container for SwiftUI previews. Seeded
//  with sample data so previews look like a real, used app instead of
//  an empty first-launch state.
//
//  ───── Why seeded, not empty? ─────
//  A blank XP bar and zero-streak badge in every preview makes it hard
//  to tell if the UI is broken or just empty. Seed values are picked
//  to exercise visible states: >0 streak, mid-level XP, a couple of
//  completed lessons so topic cards show progress, and a Bible note so
//  the Journal list has content.
//

import SwiftUI
import SwiftData

enum PreviewContainer {
    /// Shared in-memory container. Same schema as production, pre-seeded.
    @MainActor
    static let shared: ModelContainer = {
        let schema = Schema([
            LessonProgress.self,
            UserStreak.self,
            BibleNote.self,
            Prayer.self,
            SavedVerse.self,
            UserSettings.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seed(container.mainContext)
            return container
        } catch {
            fatalError("Failed to build preview container: \(error)")
        }
    }()

    // MARK: - Sample Data

    @MainActor
    private static func seed(_ ctx: ModelContext) {
        // Streak / XP — a 4-day streak, mid-level 7 (615 XP), checked in today
        // so "hasCheckedInToday" is true in previews.
        ctx.insert(UserStreak(
            currentStreak: 4,
            longestStreak: 12,
            totalXP: 615,
            lastCheckInDate: .now,
            userId: "preview-user"
        ))

        // A few completed lessons so the Creation topic shows 3/4 progress.
        ctx.insert(LessonProgress(
            topicId: "creation",
            lessonId: "creation-1",
            score: 100,
            xpEarned: 60,
            userId: "preview-user"
        ))
        ctx.insert(LessonProgress(
            topicId: "creation",
            lessonId: "creation-2",
            score: 100,
            xpEarned: 60,
            userId: "preview-user"
        ))
        ctx.insert(LessonProgress(
            topicId: "creation",
            lessonId: "creation-3",
            score: 80,
            xpEarned: 50,
            userId: "preview-user"
        ))

        // A Bible note so the Journal previews aren't empty.
        ctx.insert(BibleNote(
            book: "Psalms",
            chapter: 23,
            verse: 1,
            verseText: "The Lord is my shepherd; I shall not want.",
            note: "A comfort when I feel anxious about provision.",
            userId: "preview-user"
        ))

        // An active prayer request.
        ctx.insert(Prayer(
            title: "Wisdom for next step at work",
            content: "Asking God for clarity on whether to take the role or stay.",
            linkedVerse: "James 1:5",
            userId: "preview-user"
        ))

        // A saved verse so the Profile / saved list previews aren't empty.
        ctx.insert(SavedVerse(
            reference: "Philippians 4:13",
            text: "I can do all things through Christ who strengthens me.",
            translation: "web",
            userId: "preview-user"
        ))

        // Settings for this preview user.
        ctx.insert(UserSettings(
            displayName: "Patrick",
            userId: "preview-user"
        ))

        try? ctx.save()
    }
}
