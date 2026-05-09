// ────────────────────────────────────────────────────────────────────────────
// ScriptureReferenceParser.swift
//
// Stateless utility that converts a lesson's compound scripture reference
// string into an array of individual references that bible-api.com can
// handle one at a time.
//
// Examples:
//   "Romans 3; 5; 8"   → ["Romans 3", "Romans 5", "Romans 8"]
//   "Genesis 6-9"      → ["Genesis 6", "Genesis 7", "Genesis 8", "Genesis 9"]
//   "Psalm 23"         → ["Psalm 23"]
//   "John 3:16-18"     → ["John 3:16-18"]  (pass-through, API handles verse ranges)
//   "1 Corinthians 13; 15" → ["1 Corinthians 13", "1 Corinthians 15"]
// ────────────────────────────────────────────────────────────────────────────

import Foundation

enum ScriptureReferenceParser {

    /// Split a compound scripture reference into individual API-friendly references.
    ///
    /// The book name carries forward across semicolons. `"Romans 3; 5; 8"`
    /// means the parser sees `"Romans 3"`, then `" 5"` (no book name → reuse
    /// "Romans"), then `" 8"` (reuse "Romans").
    ///
    /// Verse-level references (containing a colon) pass through as-is — the
    /// hyphen in `"John 3:16-18"` is a verse range, not a chapter range.
    ///
    /// Numbered books (`"1 Corinthians"`, `"2 Kings"`) are handled correctly.
    static func parse(_ reference: String) -> [String] {
        let trimmed = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Split on semicolons first.
        let segments = trimmed.components(separatedBy: ";").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }

        guard !segments.isEmpty else { return [trimmed] }

        var results: [String] = []
        var lastBookName: String? = nil

        for segment in segments {
            let (book, remainder) = extractBookName(from: segment)

            if let book = book {
                // This segment has its own book name.
                lastBookName = book
                let refs = expandChapterRange(book: book, remainder: remainder)
                results.append(contentsOf: refs)
            } else if let book = lastBookName {
                // No book name in this segment — reuse the previous one.
                let refs = expandChapterRange(book: book, remainder: segment)
                results.append(contentsOf: refs)
            } else {
                // No book name found and no previous book — pass through as-is.
                results.append(segment)
            }
        }

        return results.isEmpty ? [trimmed] : results
    }

    // MARK: - Private helpers

    /// Separate the book name from the chapter/verse portion of a reference.
    ///
    /// Returns `(bookName, remainder)` where bookName is e.g. "Romans" or
    /// "1 Corinthians" and remainder is e.g. "3" or "3:16-18".
    ///
    /// Returns `(nil, original)` if no book name is detected (e.g. the segment
    /// is just "5" from splitting "Romans 3; 5; 8" on semicolons).
    private static func extractBookName(from segment: String) -> (book: String?, remainder: String) {
        let trimmed = segment.trimmingCharacters(in: .whitespacesAndNewlines)

        // A segment that is purely numeric (e.g. "5") has no book name.
        // Also handles "5-8" (range with no book).
        if trimmed.allSatisfy({ $0.isNumber || $0 == "-" || $0 == ":" || $0 == " " }) {
            return (nil, trimmed)
        }

        // Strategy: walk from the end to find where the chapter/verse number starts.
        // The book name is everything before the last space that precedes a digit.
        //
        // "Romans 3"         → book="Romans", remainder="3"
        // "1 Corinthians 13" → book="1 Corinthians", remainder="13"
        // "Song of Solomon 2" → book="Song of Solomon", remainder="2"
        // "Genesis 6-9"      → book="Genesis", remainder="6-9"
        // "John 3:16-18"     → book="John", remainder="3:16-18"

        // Find the last space that is followed by a digit.
        guard let lastSpaceBeforeDigit = findLastSpaceBeforeDigit(in: trimmed) else {
            // No space-before-digit found. Treat as a standalone book name
            // (e.g. "Psalms" with no chapter). Pass through.
            return (trimmed, "")
        }

        let book = String(trimmed[trimmed.startIndex..<lastSpaceBeforeDigit])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let remainder = String(trimmed[trimmed.index(after: lastSpaceBeforeDigit)...])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return (book, remainder)
    }

    /// Find the index of the last space character that is immediately followed
    /// by a digit character.
    private static func findLastSpaceBeforeDigit(in string: String) -> String.Index? {
        var result: String.Index? = nil
        var index = string.startIndex
        while index < string.endIndex {
            let nextIndex = string.index(after: index)
            if string[index] == " " && nextIndex < string.endIndex && string[nextIndex].isNumber {
                result = index
            }
            index = nextIndex
        }
        return result
    }

    /// Given a book name and a remainder like "6-9" or "3:16-18", expand
    /// chapter ranges into individual references.
    ///
    /// - "6-9" (no colon) → ["Genesis 6", "Genesis 7", "Genesis 8", "Genesis 9"]
    /// - "3:16-18" (has colon) → ["John 3:16-18"] (pass-through, verse range)
    /// - "3" → ["Romans 3"]
    private static func expandChapterRange(book: String, remainder: String) -> [String] {
        let trimmedRemainder = remainder.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty remainder — just the book name (unusual but handle gracefully).
        guard !trimmedRemainder.isEmpty else {
            return [book]
        }

        // If the remainder contains a colon, it's a verse-level reference.
        // Pass through as-is — the hyphen (if any) is a verse range.
        if trimmedRemainder.contains(":") {
            return ["\(book) \(trimmedRemainder)"]
        }

        // If the remainder contains a hyphen, it's a chapter range.
        if trimmedRemainder.contains("-") {
            let parts = trimmedRemainder.components(separatedBy: "-")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            if parts.count == 2,
               let start = Int(parts[0]),
               let end = Int(parts[1]),
               start <= end,
               end - start < 50 // Safety: don't expand absurdly large ranges
            {
                return (start...end).map { "\(book) \($0)" }
            }
        }

        // Simple single reference.
        return ["\(book) \(trimmedRemainder)"]
    }
}
