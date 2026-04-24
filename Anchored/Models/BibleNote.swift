//
//  BibleNote.swift
//  Anchored
//
//  A personal note anchored to a specific verse, created from the Bible
//  reader or the Journal tab. Ported from Base44's `BibleNote` entity.
//

import Foundation
import SwiftData

@Model
final class BibleNote {
    /// Bible book name — matches bible-api.com format ("John", "1 Corinthians", etc.)
    var book: String

    var chapter: Int

    var verse: Int

    /// Cached verse text at time of note creation. This preserves the user's
    /// context even if their preferred translation later changes.
    var verseText: String

    /// The user's reflection. Plain text for v1 (simple rich text via attributed
    /// markdown in the editor is possible later without a model migration).
    var note: String

    var createdAt: Date
    var updatedAt: Date

    var userId: String?

    init(
        book: String,
        chapter: Int,
        verse: Int,
        verseText: String,
        note: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        userId: String? = nil
    ) {
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.verseText = verseText
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }

    /// Formatted reference like "John 3:16".
    var reference: String { "\(book) \(chapter):\(verse)" }
}
