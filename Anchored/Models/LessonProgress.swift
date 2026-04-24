//
//  LessonProgress.swift
//  Anchored
//
//  Tracks completion state for a single lesson. Created or updated when
//  the user finishes the quiz at the end of a lesson.
//
//  Ported from the Base44 `LessonProgress` entity with the same fields.
//

import Foundation
import SwiftData

@Model
final class LessonProgress {
    /// ID of the parent topic (e.g. "creation").
    var topicId: String

    /// ID of the lesson within the topic (e.g. "creation-1").
    @Attribute(.unique) var lessonId: String

    /// Whether the user finished the quiz (reading the teaching alone doesn't count).
    var completed: Bool

    /// Percentage score on the quiz (0–100).
    var score: Int

    /// XP awarded for this attempt.
    var xpEarned: Int

    /// Timestamp of most recent completion — used for streak calculation.
    var completedAt: Date

    /// Optional user identifier (Sign in with Apple `user` string). We capture
    /// this now so progress can later sync per-account via CloudKit without a
    /// migration. For v1 there's a single local user.
    var userId: String?

    init(
        topicId: String,
        lessonId: String,
        completed: Bool = true,
        score: Int,
        xpEarned: Int,
        completedAt: Date = .now,
        userId: String? = nil
    ) {
        self.topicId = topicId
        self.lessonId = lessonId
        self.completed = completed
        self.score = score
        self.xpEarned = xpEarned
        self.completedAt = completedAt
        self.userId = userId
    }
}
