# Scripture Reading Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 73/176 lessons that show human-written summaries instead of actual Bible text by parsing compound scripture references, fetching chapters individually, and presenting them one at a time with per-chapter comprehension quizzes.

**Architecture:** A pure `ScriptureReferenceParser` (enum with static methods) splits compound references into individual API-friendly strings. `LessonView` is rewritten with a chapter-paged reading flow that fetches all chapters concurrently and presents them one at a time, with an optional comprehension quiz after each chapter (iOS 26+ only via Foundation Models). The `teaching` field moves to a post-reading commentary section, never displayed as a scripture substitute.

**Tech Stack:** SwiftUI, SwiftData, async/await with TaskGroup, Foundation Models (iOS 26+ gated via `#if canImport(FoundationModels)` + `@available(iOS 26.0, *)`)

---

## File Structure

### New Files
- `Anchored/Services/ScriptureReferenceParser.swift` — Pure stateless parser (enum with static methods). Converts compound scripture reference strings into arrays of individual API-friendly references.
- `Anchored/Services/ChapterQuizGenerator.swift` — Foundation Models quiz generation service (iOS 26+ only). Generates 1-2 comprehension questions from a `BiblePassage`.

### Modified Files
- `Anchored/Features/Lesson/LessonView.swift` — Major rewrite. New phase model with chapter-paged reading, concurrent multi-fetch, teaching as post-reading commentary, comprehension check integration.

### Unchanged Files (reference only)
- `Anchored/Services/BibleAPIService.swift` — Still fetches one reference at a time. No changes needed.
- `Anchored/Features/Quiz/QuizQuestionCard.swift` — Reused unchanged for both comprehension checks and the final quiz.
- `Anchored/Content/TopicCatalog.swift` — `Lesson` struct stays the same. `scripture`, `teaching`, `keyVerse`, `questions` fields all unchanged.

---

### Task 1: ScriptureReferenceParser

**Files:**
- Create: `Anchored/Services/ScriptureReferenceParser.swift`

This is a pure, stateless utility with no dependencies. It converts the `lesson.scripture` string (e.g. `"Romans 3; 5; 8"`) into an array of individual references (e.g. `["Romans 3", "Romans 5", "Romans 8"]`) that `BibleAPIService` can handle one at a time.

- [ ] **Step 1: Create `ScriptureReferenceParser.swift` with the full implementation**

Create `Anchored/Services/ScriptureReferenceParser.swift`:

```swift
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
```

- [ ] **Step 2: Verify the new file compiles by checking for syntax issues**

Open the file in Xcode or run `xcodegen generate` then build. Expected: no errors — this is a pure Swift file with no external dependencies (only `import Foundation`).

- [ ] **Step 3: Spot-check parsing logic manually**

In a Swift playground or by adding temporary print statements, verify:
- `ScriptureReferenceParser.parse("Romans 3; 5; 8")` → `["Romans 3", "Romans 5", "Romans 8"]`
- `ScriptureReferenceParser.parse("Genesis 6-9")` → `["Genesis 6", "Genesis 7", "Genesis 8", "Genesis 9"]`
- `ScriptureReferenceParser.parse("Psalm 23")` → `["Psalm 23"]`
- `ScriptureReferenceParser.parse("John 3:16-18")` → `["John 3:16-18"]`
- `ScriptureReferenceParser.parse("1 Corinthians 13; 15")` → `["1 Corinthians 13", "1 Corinthians 15"]`

- [ ] **Step 4: Commit**

```bash
git add Anchored/Services/ScriptureReferenceParser.swift
git commit -m "feat: add ScriptureReferenceParser for compound scripture references

Splits semicolons ('Romans 3; 5; 8') and chapter ranges ('Genesis 6-9')
into individual references that bible-api.com can handle one at a time.
Verse-level references pass through unchanged."
```

---

### Task 2: ChapterQuizGenerator

**Files:**
- Create: `Anchored/Services/ChapterQuizGenerator.swift`

This service uses Apple Foundation Models (iOS 26+ only) to generate 1-2 comprehension questions after each chapter reading. It returns `[QuizQuestion]` — the same type used by hand-written questions — so `QuizQuestionCard` works unchanged.

On iOS < 26 or if generation fails, it returns an empty array. Callers skip the comprehension check when the array is empty.

- [ ] **Step 1: Create `ChapterQuizGenerator.swift` with the full implementation**

Create `Anchored/Services/ChapterQuizGenerator.swift`:

```swift
// ────────────────────────────────────────────────────────────────────────────
// ChapterQuizGenerator.swift
//
// Uses Apple Foundation Models (iOS 26+) to generate 1-2 comprehension
// questions from a Bible passage the user just read. Returns [QuizQuestion]
// — the same type used by hand-written questions — so QuizQuestionCard
// works unchanged for both comprehension checks and the final quiz.
//
// Gating:
//   - #if canImport(FoundationModels) — compile-time gate for older SDKs
//   - @available(iOS 26.0, *) — runtime gate for older devices
//
// Fallback:
//   - Returns empty array on iOS < 26 or if generation fails
//   - Callers skip the comprehension check when array is empty
//   - Comprehension checks are an enhancement, not a gate
// ────────────────────────────────────────────────────────────────────────────

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Public interface
// ─────────────────────────────────────────────────────────────────────────────

@MainActor
final class ChapterQuizGenerator {

    static let shared = ChapterQuizGenerator()
    private init() {}

    /// Generate 1-2 comprehension questions for a Bible passage.
    /// Returns empty array on iOS < 26 or if generation fails.
    func generate(for passage: BiblePassage) async -> [QuizQuestion] {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generateWithFoundationModels(passage: passage)
        }
        #endif
        return []
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Foundation Models implementation
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(FoundationModels)

@available(iOS 26.0, *)
@Generable
private struct GeneratedQuiz {
    @Guide(description: "An array of 1 to 2 multiple-choice comprehension questions about the Bible passage.")
    let questions: [GeneratedQuestion]
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedQuestion {
    @Guide(description: "The question text. A simple factual question about what happens in the passage.")
    let prompt: String

    @Guide(description: "Exactly 4 answer options. One must be correct.")
    let options: [String]

    @Guide(description: "The zero-based index of the correct option (0, 1, 2, or 3).")
    let correctIndex: Int

    @Guide(description: "A 1-2 sentence explanation of the correct answer, referencing the passage.")
    let explanation: String
}

@available(iOS 26.0, *)
extension ChapterQuizGenerator {

    fileprivate func generateWithFoundationModels(passage: BiblePassage) async -> [QuizQuestion] {
        let instructions = """
        You are a Bible reading comprehension quiz maker. Given a Bible passage, \
        create 1-2 simple factual multiple-choice questions about what happens in \
        the passage. Each question has exactly 4 options with one correct answer. \
        Questions should be answerable by someone who just read the passage — no \
        trick questions, no theological interpretation, just reading comprehension. \
        Keep questions and options concise.
        """

        // Build a condensed version of the passage text for the prompt.
        let verseText = passage.verses.map { "(\($0.verse)) \($0.text)" }.joined(separator: " ")
        let prompt = """
        Bible passage — \(passage.reference):

        \(verseText)

        Create 1-2 comprehension questions about this passage.
        """

        do {
            let session = LanguageModelSession(instructions: instructions)

            // Race against an 8-second timeout (same pattern as VerseRecommenderService).
            let result: [QuizQuestion]? = try await withThrowingTaskGroup(
                of: [QuizQuestion]?.self
            ) { group in
                group.addTask {
                    let response = try await session.respond(
                        to: prompt,
                        generating: GeneratedQuiz.self
                    )
                    return response.content.toQuizQuestions()
                }
                group.addTask {
                    try await Task.sleep(for: .seconds(8))
                    throw CancellationError()
                }
                let value = try await group.next()
                group.cancelAll()
                return value ?? nil
            }
            return result ?? []
        } catch {
            // Timeout or model error — skip comprehension check silently.
            return []
        }
    }
}

@available(iOS 26.0, *)
private extension GeneratedQuiz {
    /// Convert the model's @Generable output into the app's QuizQuestion type.
    func toQuizQuestions() -> [QuizQuestion] {
        questions.compactMap { q in
            // Validate: need exactly 4 options and a valid correctIndex.
            guard q.options.count == 4,
                  (0...3).contains(q.correctIndex) else {
                return nil
            }
            return QuizQuestion(
                prompt: q.prompt,
                options: q.options,
                correctIndex: q.correctIndex,
                explanation: q.explanation
            )
        }
    }
}

#endif
```

- [ ] **Step 2: Verify the file compiles**

Run `xcodegen generate` then build. Expected: no errors. The `#if canImport(FoundationModels)` gate means this compiles cleanly on both Xcode 16 (no FoundationModels) and Xcode 26 beta.

- [ ] **Step 3: Commit**

```bash
git add Anchored/Services/ChapterQuizGenerator.swift
git commit -m "feat: add ChapterQuizGenerator for per-chapter comprehension quizzes

Uses Foundation Models (iOS 26+) to generate 1-2 reading comprehension
questions after each chapter. Returns [QuizQuestion] so QuizQuestionCard
works unchanged. Returns empty array on iOS < 26 or if generation fails."
```

---

### Task 3: Rewrite LessonView with chapter-paged reading flow

**Files:**
- Modify: `Anchored/Features/Lesson/LessonView.swift` (full rewrite — 596 lines → ~700 lines)

This is the core change. The current `LessonView` has three phases (reading → quiz → results). The new version has a chapter-paged flow:

```
.reading(chapterIndex) → .chapterQuiz(chapterIndex) → ... → .teaching → .quiz → .results
```

Key changes:
1. **Phase model** becomes an enum with associated values for chapter index
2. **`loadScripture()`** uses `ScriptureReferenceParser` + concurrent fetching via `TaskGroup`
3. **Reading phase** shows one chapter at a time with "Next" navigation
4. **Chapter quiz** (iOS 26+) shows 1-2 comprehension questions between chapters
5. **Teaching phase** is new — shows `lesson.teaching` as commentary after all reading, before quiz
6. **Error handling** shows retry buttons per chapter, never falls back to `lesson.teaching`

- [ ] **Step 1: Replace `LessonView.swift` with the complete new implementation**

Replace the entire contents of `Anchored/Features/Lesson/LessonView.swift` with:

```swift
// ────────────────────────────────────────────────────────────────────────────
// LessonView.swift
//
// The heart of the learning flow. A multi-phase screen:
//
//   1. READING  — Bible text displayed one chapter at a time with "Next"
//                 navigation. Compound references (e.g. "Romans 3; 5; 8")
//                 are parsed and fetched concurrently.
//   2. CHAPTER QUIZ (iOS 26+ only) — 1-2 generated comprehension questions
//                 after each chapter, using Foundation Models.
//   3. TEACHING — lesson.teaching shown as post-reading commentary/context.
//                 Never displayed as a scripture substitute.
//   4. QUIZ     — Hand-written QuizQuestionCard questions with combo badge.
//   5. RESULTS  — Animated score ring, XP breakdown, wrong-answer review.
//
// Integration points:
//   • Constructed with a Topic + Lesson (Hashable) via NavigationStack route.
//   • Uses @Environment(StreakManager.self) to award XP and check in.
//   • Writes a LessonProgress row on completion. lessonId is @Attribute(.unique),
//     so retakes UPDATE the existing row — never insert a duplicate.
//
// XP math (unchanged from original):
//   • +10 per correct answer (final quiz only)
//   • +5 combo bonus for each correct answer that extends a streak of 3+
//   • +50 perfect-score bonus
//   • +25 first-time-completion bonus
//   No XP for comprehension checks.
// ────────────────────────────────────────────────────────────────────────────

import SwiftUI
import SwiftData

struct LessonView: View {
    let topic: Topic
    let lesson: Lesson

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StreakManager.self) private var streakManager
    @EnvironmentObject private var premiumManager: PremiumManager

    @State private var priorProgress: LessonProgress? = nil

    // MARK: - Scripture fetch

    @AppStorage("preferredBibleTranslation") private var preferredTranslation: BibleTranslation = .web

    /// Parsed individual references from ScriptureReferenceParser.
    @State private var chapterReferences: [String] = []
    /// Fetched passages indexed by chapter position. nil = not yet loaded.
    @State private var chapterPassages: [Int: BiblePassage] = [:]
    /// Per-chapter loading state.
    @State private var chapterLoading: [Int: Bool] = [:]
    /// Per-chapter error state.
    @State private var chapterErrors: [Int: Error] = [:]

    // MARK: - Comprehension quiz state

    /// Generated comprehension questions per chapter index.
    @State private var comprehensionQuestions: [Int: [QuizQuestion]] = [:]
    @State private var comprehensionIndex = 0
    @State private var comprehensionAnswered = false

    // MARK: - Flow state

    private enum Phase: Equatable {
        case reading(chapterIndex: Int)
        case chapterQuiz(chapterIndex: Int)
        case teaching
        case quiz
        case results
    }

    @State private var phase: Phase = .reading(chapterIndex: 0)

    // Final quiz state
    @State private var currentIndex = 0
    @State private var combo = 0
    @State private var answers: [AnswerRecord] = []
    @State private var earnedXP = 0

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch phase {
                case .reading(let chapterIndex):
                    chapterReadingPhase(chapterIndex: chapterIndex)
                case .chapterQuiz(let chapterIndex):
                    chapterQuizPhase(chapterIndex: chapterIndex)
                case .teaching:
                    teachingPhase
                case .quiz:
                    quizPhase
                case .results:
                    resultsPhase
                }
            }
            .screenPadding()
            .padding(.top, 8)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadPriorProgress()
            await loadAllChapters()
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 1: Chapter Reading
    // ────────────────────────────────────────────────────────────────────

    private func chapterReadingPhase(chapterIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scripture reference pill.
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                Text(lesson.scripture)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundStyle(AnchoredColors.amber)

            // Chapter progress indicator (only when multiple chapters).
            if chapterReferences.count > 1 {
                chapterProgressIndicator(current: chapterIndex)
            }

            // Chapter content.
            VStack(alignment: .leading, spacing: 10) {
                if chapterReferences.indices.contains(chapterIndex) {
                    Text(chapterReferences[chapterIndex])
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AnchoredColors.amber)
                        .textCase(.uppercase)
                }

                if chapterLoading[chapterIndex] == true {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                } else if let passage = chapterPassages[chapterIndex] {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(passage.verses, id: \.self) { verse in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("\(verse.verse)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AnchoredColors.amber)
                                    .frame(minWidth: 18, alignment: .trailing)
                                Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .anchoredStyle(.scripture)
                                    .foregroundStyle(AnchoredColors.navy)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                } else if chapterErrors[chapterIndex] != nil {
                    // Error state — retry button, never fall back to lesson.teaching.
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundStyle(AnchoredColors.amber)
                        Text("Could not load this chapter.")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.navy)
                        Button {
                            Task { await retryChapter(chapterIndex) }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry")
                                    .font(.system(.callout, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(AnchoredColors.amber, in: Capsule())
                            .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    // Still loading (initial state before task kicks off).
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .cardSurface(padding: 16)

            // Key verse pull-quote (show on first chapter only to avoid repetition).
            if chapterIndex == 0 {
                keyVerseCard
            }

            // Next / Start Teaching / Start Challenge button.
            chapterNavigationButton(chapterIndex: chapterIndex)
        }
        .transition(.opacity)
    }

    private func chapterProgressIndicator(current: Int) -> some View {
        HStack(spacing: 8) {
            Text("Chapter \(current + 1) of \(chapterReferences.count)")
                .font(.caption.weight(.medium))
                .foregroundStyle(AnchoredColors.muted)
                .textCase(.uppercase)

            Spacer()

            // Progress dots.
            HStack(spacing: 4) {
                ForEach(0..<chapterReferences.count, id: \.self) { i in
                    Capsule()
                        .fill(i < current ? AnchoredColors.amber :
                              i == current ? AnchoredColors.amber.opacity(0.5) :
                              AnchoredColors.muted.opacity(0.3))
                        .frame(width: 18, height: 4)
                }
            }
        }
    }

    private var keyVerseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Verse")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AnchoredColors.amber)
                .textCase(.uppercase)
            Text(lesson.keyVerse)
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AnchoredColors.amber.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AnchoredColors.amber.opacity(0.25), lineWidth: 1)
        )
    }

    /// The button at the bottom of the reading phase. Advances to next chapter,
    /// comprehension quiz, teaching, or the hand-written quiz.
    private func chapterNavigationButton(chapterIndex: Int) -> some View {
        let isLastChapter = chapterIndex + 1 >= chapterReferences.count
        let hasPassage = chapterPassages[chapterIndex] != nil
        let buttonLabel = isLastChapter ? "Continue to Reflection" : "Next Chapter"
        let buttonIcon = isLastChapter ? "text.quote" : "arrow.right"

        return Button {
            advanceFromReading(chapterIndex: chapterIndex)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: buttonIcon)
                Text(buttonLabel)
                    .font(.system(.body, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AnchoredColors.amber, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: AnchoredColors.amber.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .disabled(!hasPassage)
        .opacity(hasPassage ? 1 : 0.5)
    }

    /// Decide what comes after reading a chapter: comprehension quiz (iOS 26+)
    /// or advance to next chapter / teaching.
    private func advanceFromReading(chapterIndex: Int) {
        // Check if we have comprehension questions for this chapter.
        if let questions = comprehensionQuestions[chapterIndex], !questions.isEmpty {
            withAnimation(.easeInOut(duration: 0.25)) {
                comprehensionIndex = 0
                comprehensionAnswered = false
                phase = .chapterQuiz(chapterIndex: chapterIndex)
            }
        } else {
            advanceFromChapterQuiz(chapterIndex: chapterIndex)
        }
    }

    /// Advance past a chapter quiz (or skip if none) to the next chapter or teaching.
    private func advanceFromChapterQuiz(chapterIndex: Int) {
        let nextChapter = chapterIndex + 1
        if nextChapter < chapterReferences.count {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .reading(chapterIndex: nextChapter)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .teaching
            }
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 2: Chapter Comprehension Quiz (iOS 26+ only)
    // ────────────────────────────────────────────────────────────────────

    private func chapterQuizPhase(chapterIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header.
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                Text("Comprehension Check")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundStyle(AnchoredColors.amber)

            if chapterReferences.count > 1 {
                Text(chapterReferences[chapterIndex])
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AnchoredColors.muted)
            }

            if let questions = comprehensionQuestions[chapterIndex],
               comprehensionIndex < questions.count {
                QuizQuestionCard(
                    question: questions[comprehensionIndex],
                    questionIndex: comprehensionIndex,
                    totalQuestions: questions.count,
                    shuffleSeed: lesson.id.hashValue &+ chapterIndex &* 1000 &+ comprehensionIndex,
                    onAnswer: { _, _ in
                        // No XP for comprehension checks. No combo tracking.
                        comprehensionAnswered = true
                    },
                    onContinue: {
                        let questions = comprehensionQuestions[chapterIndex] ?? []
                        if comprehensionIndex + 1 < questions.count {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                comprehensionIndex += 1
                                comprehensionAnswered = false
                            }
                        } else {
                            advanceFromChapterQuiz(chapterIndex: chapterIndex)
                        }
                    }
                )
                .id("comp-\(chapterIndex)-\(comprehensionIndex)")
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .transition(.opacity)
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 3: Teaching (Post-Reading Commentary)
    // ────────────────────────────────────────────────────────────────────

    private var teachingPhase: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: "text.quote")
                Text("Reflection & Context")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundStyle(AnchoredColors.amber)

            Text(lesson.teaching)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.navy)
                .fixedSize(horizontal: false, vertical: true)
                .cardSurface(padding: 16)

            // Key verse reminder.
            keyVerseCard

            // Start Challenge button.
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { phase = .quiz }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Start Challenge")
                        .font(.system(.body, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AnchoredColors.amber, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(.white)
                .shadow(color: AnchoredColors.amber.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .transition(.opacity)
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 4: Quiz (Hand-Written Questions)
    // ────────────────────────────────────────────────────────────────────

    private var quizPhase: some View {
        VStack(alignment: .leading, spacing: 16) {
            if combo >= 2 {
                comboBadge
            }

            QuizQuestionCard(
                question: lesson.questions[currentIndex],
                questionIndex: currentIndex,
                totalQuestions: lesson.questions.count,
                shuffleSeed: lesson.id.hashValue &+ currentIndex,
                onAnswer: { wasCorrect, userAnswer in
                    handleAnswer(wasCorrect: wasCorrect, userAnswer: userAnswer)
                },
                onContinue: {
                    advanceOrFinish()
                }
            )
            .id(currentIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal:   .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .transition(.opacity)
    }

    private var comboBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(combo)× Combo")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            LinearGradient(colors: [.orange, .red],
                           startPoint: .leading, endPoint: .trailing),
            in: Capsule()
        )
        .shadow(color: .orange.opacity(0.35), radius: 6, y: 2)
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 5: Results
    // ────────────────────────────────────────────────────────────────────

    private var resultsPhase: some View {
        VStack(spacing: 24) {
            scoreRing
            xpBreakdown

            if !wrongAnswers.isEmpty {
                reviewSection
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(.body, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AnchoredColors.amber, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    private var scoreRing: some View {
        let pct = Double(scorePercent) / 100.0
        let ringColor: Color = {
            if scorePercent >= 80 { return .green }
            if scorePercent >= 50 { return AnchoredColors.amber }
            return .orange
        }()
        return VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(AnchoredColors.muted.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.9, dampingFraction: 0.8), value: pct)
                VStack(spacing: 2) {
                    Text("\(scorePercent)%")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AnchoredColors.navy)
                    Text("\(correctCount)/\(answers.count)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AnchoredColors.muted)
                }
            }
            .frame(width: 140, height: 140)

            Text(resultHeadline)
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(AnchoredColors.navy)
        }
        .padding(.top, 12)
    }

    private var xpBreakdown: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(AnchoredColors.amber)
                Text("XP Earned")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Text("+\(earnedXP)")
                    .font(.system(.title3, weight: .bold))
                    .foregroundStyle(AnchoredColors.amber)
            }
            Divider()
            xpLine(label: "Correct answers", value: correctCount * 10)
            if comboBonusTotal > 0 {
                xpLine(label: "Combo bonus", value: comboBonusTotal)
            }
            if scorePercent == 100 {
                xpLine(label: "Perfect score", value: 50)
            }
            if isFirstCompletion {
                xpLine(label: "First completion", value: 25)
            }
        }
        .cardSurface(padding: 16)
    }

    private func xpLine(label: String, value: Int) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(AnchoredColors.muted)
            Spacer()
            Text("+\(value)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AnchoredColors.navy)
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "text.magnifyingglass")
                Text("Review (\(wrongAnswers.count))")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(AnchoredColors.navy)

            ForEach(Array(wrongAnswers.enumerated()), id: \.offset) { _, record in
                ReviewCard(record: record)
            }
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Quiz Handlers
    // ────────────────────────────────────────────────────────────────────

    private func handleAnswer(wasCorrect: Bool, userAnswer: String) {
        let question = lesson.questions[currentIndex]
        let correctText = question.options[question.correctIndex]
        answers.append(AnswerRecord(
            question: question,
            userAnswer: userAnswer,
            correctAnswer: correctText,
            wasCorrect: wasCorrect
        ))

        if wasCorrect {
            combo += 1
        } else {
            combo = 0
        }
    }

    private func advanceOrFinish() {
        if currentIndex + 1 < lesson.questions.count {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
            }
        } else {
            finishLesson()
        }
    }

    private func finishLesson() {
        earnedXP = calculateXP()
        persistProgress(xp: earnedXP)
        streakManager.awardXP(earnedXP)
        streakManager.checkIn()

        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .results
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Derived
    // ────────────────────────────────────────────────────────────────────

    private var correctCount: Int { answers.filter(\.wasCorrect).count }

    private var scorePercent: Int {
        guard !answers.isEmpty else { return 0 }
        return Int((Double(correctCount) / Double(answers.count)) * 100.0)
    }

    private var wrongAnswers: [AnswerRecord] { answers.filter { !$0.wasCorrect } }

    private var isFirstCompletion: Bool {
        priorProgress?.completed != true
    }

    private var resultHeadline: String {
        switch scorePercent {
        case 100: return "Perfect!"
        case 80...: return "Great work"
        case 50...: return "Nice effort"
        default:    return "Keep going"
        }
    }

    private var comboBonusTotal: Int {
        var running = 0
        var bonus = 0
        for answer in answers {
            if answer.wasCorrect {
                running += 1
                if running >= 3 { bonus += 5 }
            } else {
                running = 0
            }
        }
        return bonus
    }

    private func calculateXP() -> Int {
        var total = correctCount * 10
        total += comboBonusTotal
        if scorePercent == 100 { total += 50 }
        if isFirstCompletion   { total += 25 }
        return total
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Data Loading
    // ────────────────────────────────────────────────────────────────────

    /// Parse the compound reference and fetch all chapters concurrently.
    private func loadAllChapters() async {
        let refs = ScriptureReferenceParser.parse(lesson.scripture)
        chapterReferences = refs

        let translation = (preferredTranslation.isFree || premiumManager.isPremium)
            ? preferredTranslation : .web

        // Fetch all chapters concurrently using TaskGroup.
        await withTaskGroup(of: (Int, Result<BiblePassage, Error>).self) { group in
            for (index, ref) in refs.enumerated() {
                chapterLoading[index] = true
                group.addTask {
                    do {
                        let passage = try await BibleAPIService.shared.fetch(
                            reference: ref,
                            translation: translation
                        )
                        return (index, .success(passage))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }

            for await (index, result) in group {
                chapterLoading[index] = false
                switch result {
                case .success(let passage):
                    chapterPassages[index] = passage
                    // Start generating comprehension questions for this chapter
                    // in the background as soon as it loads.
                    Task {
                        let questions = await ChapterQuizGenerator.shared.generate(for: passage)
                        comprehensionQuestions[index] = questions
                    }
                case .failure(let error):
                    chapterErrors[index] = error
                }
            }
        }
    }

    /// Retry a single chapter that previously failed.
    private func retryChapter(_ index: Int) async {
        guard chapterReferences.indices.contains(index) else { return }

        chapterLoading[index] = true
        chapterErrors[index] = nil

        let translation = (preferredTranslation.isFree || premiumManager.isPremium)
            ? preferredTranslation : .web

        do {
            let passage = try await BibleAPIService.shared.fetch(
                reference: chapterReferences[index],
                translation: translation
            )
            chapterPassages[index] = passage
            chapterLoading[index] = false

            // Generate comprehension questions for the retried chapter.
            Task {
                let questions = await ChapterQuizGenerator.shared.generate(for: passage)
                comprehensionQuestions[index] = questions
            }
        } catch {
            chapterErrors[index] = error
            chapterLoading[index] = false
        }
    }

    private func loadPriorProgress() {
        let lessonId = lesson.id
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.lessonId == lessonId }
        )
        priorProgress = try? modelContext.fetch(descriptor).first
    }

    private func persistProgress(xp: Int) {
        let lessonId = lesson.id
        let topicId = topic.id
        let newScore = scorePercent

        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.lessonId == lessonId }
        )

        do {
            if let existing = try modelContext.fetch(descriptor).first {
                existing.completed = true
                existing.score = max(existing.score, newScore)
                existing.xpEarned += xp
                existing.completedAt = .now
            } else {
                let fresh = LessonProgress(
                    topicId: topicId,
                    lessonId: lessonId,
                    completed: true,
                    score: newScore,
                    xpEarned: xp,
                    completedAt: .now
                )
                modelContext.insert(fresh)
            }
            try modelContext.save()
        } catch {
            assertionFailure("LessonProgress save failed: \(error)")
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - AnswerRecord
// ────────────────────────────────────────────────────────────────────────────

private struct AnswerRecord {
    let question: QuizQuestion
    let userAnswer: String
    let correctAnswer: String
    let wasCorrect: Bool
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - ReviewCard
// ────────────────────────────────────────────────────────────────────────────

private struct ReviewCard: View {
    let record: AnswerRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(record.question.prompt)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AnchoredColors.navy)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                answerRow(label: "Your answer", text: record.userAnswer,
                          color: .red, icon: "xmark.circle.fill")
                answerRow(label: "Correct",     text: record.correctAnswer,
                          color: .green, icon: "checkmark.circle.fill")
            }

            Text(record.question.explanation)
                .font(.caption)
                .foregroundStyle(AnchoredColors.muted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .cardSurface(padding: 14)
    }

    private func answerRow(label: String, text: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 14, weight: .semibold))
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AnchoredColors.muted)
                    .textCase(.uppercase)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(AnchoredColors.navy)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Preview
// ────────────────────────────────────────────────────────────────────────────

#Preview("Reading phase") {
    let topic = TopicsCatalog.all.first!
    let lesson = topic.lessons.first!
    let container = PreviewContainer.shared
    let manager = StreakManager(
        modelContext: container.mainContext,
        userId: "preview-user"
    )
    return NavigationStack {
        LessonView(topic: topic, lesson: lesson)
    }
    .modelContainer(container)
    .environment(manager)
    .environmentObject(PremiumManager.preview)
}
```

- [ ] **Step 2: Run `xcodegen generate` and build**

```bash
cd /path/to/Anchored
xcodegen generate
```

Then build in Xcode (⌘B). Expected: clean build, no errors.

Common issues to check:
- `AnchoredColors.muted` — verify this property exists (used in the original code, should be fine)
- `LessonProgress` init — make sure the initializer matches (it takes `topicId`, `lessonId`, `completed`, `score`, `xpEarned`, `completedAt`)
- `StreakManager.awardXP()` and `.checkIn()` — same signatures as before

- [ ] **Step 3: Verify `#Preview` macro renders without crashes**

Open the Canvas in Xcode for `LessonView.swift`. The preview should:
- Show the first lesson from the first topic
- Display the chapter reading phase with verse text
- Not crash or show blank content

- [ ] **Step 4: Commit**

```bash
git add Anchored/Features/Lesson/LessonView.swift
git commit -m "feat: rewrite LessonView with chapter-paged reading flow

Fixes 73/176 lessons that showed summaries instead of actual Bible text.
Compound scripture references are now parsed into individual chapters and
fetched concurrently. Chapters are presented one at a time with a progress
indicator. Teaching text appears as post-reading commentary, never as a
scripture substitute. Per-chapter comprehension quizzes (iOS 26+ only)
are generated via Foundation Models between chapters."
```

---

### Task 4: Regenerate Xcode project and full verification

**Files:**
- No code changes — this task verifies everything works together.

- [ ] **Step 1: Regenerate the Xcode project**

```bash
cd /path/to/Anchored
xcodegen generate
```

Expected output: `⚙️  Generating plists...` followed by `Created project Anchored.xcodeproj`

This picks up the two new files (`ScriptureReferenceParser.swift`, `ChapterQuizGenerator.swift`).

- [ ] **Step 2: Build in Xcode**

Open `Anchored.xcodeproj` and build (⌘B). Expected: clean build with zero errors.

- [ ] **Step 3: Run through the verification checklist**

Test each item from the design spec's verification checklist:

1. **Single-chapter lessons** (`"Psalm 23"`): read → teaching → quiz → results. Should work identically to before except teaching is now a separate phase after reading.
2. **Semicolon references** (`"Romans 3; 5; 8"`): should show three separate chapters with "Chapter 1 of 3" progress indicator and "Next Chapter" button.
3. **Hyphenated ranges** (`"Genesis 6-9"`): should expand to four chapters with paging.
4. **Verse-level references** (`"John 3:16-18"`): should pass through and fetch correctly as a single chapter.
5. **Teaching text**: appears after all reading, before the quiz — never as a scripture substitute.
6. **Failed chapter fetch**: shows retry button, not teaching fallback. (Test by enabling airplane mode.)
7. **All chapters fetched concurrently**: the user can start reading chapter 1 while others load.
8. **Chapter progress indicator**: shows "Chapter 2 of 3" style position.
9. **(iOS 26+) Comprehension questions**: appear after each chapter.
10. **(iOS 26+) Comprehension questions use QuizQuestionCard**: same card component.
11. **(iOS 26+) No XP for comprehension checks**: XP only from final quiz.
12. **(iOS < 26) Comprehension checks skipped**: chapters flow directly to next.
13. **(iOS 26+) Failed quiz generation**: skips silently to next chapter.
14. **Hand-written quiz**: still works in the final quiz phase.
15. **XP calculation unchanged**: based on final quiz only.
16. **`#Preview` macros**: render without crashes.

- [ ] **Step 4: Commit any fixes from verification**

If any issues were found and fixed during verification:

```bash
git add -A
git commit -m "fix: address issues found during scripture reading verification"
```

If no issues, skip this step.
