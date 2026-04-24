//
//  SavedVerse.swift
//  Anchored
//
//  A verse the user has favorited (e.g. tapped the heart on the daily
//  verse card). Lightweight — we store the reference, text, and
//  translation at time of save so the favorite is stable even if the
//  user later changes their default translation.
//

import Foundation
import SwiftData

@Model
final class SavedVerse {
    /// Verse reference like "John 3:16" or "Ruth 1:16-17".
    var reference: String

    /// The verse text at time of save.
    var text: String

    /// Translation identifier (e.g. "web", "kjv", "asv"). See BibleAPIService.
    var translation: String

    var savedAt: Date

    var userId: String?

    /// User's personal reflection on this verse. Nil if no note has been added.
    var note: String?

    /// Highlight color identifier — one of "yellow", "green", "blue", "pink", "purple". Nil = no highlight.
    var highlightColor: String?

    init(
        reference: String,
        text: String,
        translation: String,
        savedAt: Date = .now,
        userId: String? = nil,
        note: String? = nil,
        highlightColor: String? = nil
    ) {
        self.reference = reference
        self.text = text
        self.translation = translation
        self.savedAt = savedAt
        self.userId = userId
        self.note = note
        self.highlightColor = highlightColor
    }
}
