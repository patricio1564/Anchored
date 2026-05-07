# Scripture Reading Fix — Design Spec

**Date:** 2026-05-07
**Status:** Approved

## Problem

41% of lessons (73 of 176) show human-written summaries instead of actual Bible text. This happens because `BibleAPIService` passes the raw `lesson.scripture` string to `bible-api.com`, which can't handle:
- Semicolon-separated references (`"Romans 3; 5; 8"` → "not found")
- Multi-chapter ranges (`"Genesis 6-9"` → "too many chapters")

When the fetch fails, `LessonView` silently falls back to `lesson.teaching` — a commentary paragraph — displayed under a "Scripture" heading with no indication that actual scripture failed to load.

## Solution

Parse compound scripture references into individual chapter references, fetch each chapter separately, and present them one at a time with a "Next Chapter" pager. Per-chapter comprehension quizzes (iOS 26+ only) reinforce reading. The `teaching` field becomes a post-reading commentary, never a scripture substitute.

## 1. ScriptureReferenceParser

**File:** `Anchored/Services/ScriptureReferenceParser.swift`

A stateless utility (enum with static methods) that converts a `lesson.scripture` string into an array of individual references that `bible-api.com` can handle.

### Parsing Rules

| Input format | Example | Output |
|---|---|---|
| Semicolons (chapters of same book) | `"Romans 3; 5; 8"` | `["Romans 3", "Romans 5", "Romans 8"]` |
| Hyphenated chapter range | `"Genesis 6-9"` | `["Genesis 6", "Genesis 7", "Genesis 8", "Genesis 9"]` |
| Simple single reference | `"Psalm 23"` | `["Psalm 23"]` |
| Verse-level reference | `"John 3:16-18"` | `["John 3:16-18"]` (pass-through, API handles these) |
| Semicolons with different books | `"Genesis 15; 17"` | `["Genesis 15", "Genesis 17"]` (book name carries forward) |

### Interface

```swift
enum ScriptureReferenceParser {
    /// Split a compound scripture reference into individual API-friendly references.
    static func parse(_ reference: String) -> [String]
}
```

The book name carries forward across semicolons. `"Romans 3; 5; 8"` means the parser sees `"Romans 3"`, then `"5"` (no book name → reuse "Romans"), then `"8"` (reuse "Romans").

Verse-level references (containing a colon like `"John 3:16-18"`) pass through as-is — the hyphen is a verse range, not a chapter range.

Numbered books (like `"1 Corinthians"`, `"2 Kings"`) are handled correctly — the book name includes the leading number. `"1 Corinthians 13; 15"` → `["1 Corinthians 13", "1 Corinthians 15"]`.

## 2. Revised LessonView Flow

### Phase Model

Current: `.reading` → `.quiz` → `.results`

New:
```
.reading(chapterIndex: Int) → .chapterQuiz(chapterIndex: Int) → ... → .teaching → .quiz → .results
```

### Walkthrough: "Romans 3; 5; 8"

1. Parser produces `["Romans 3", "Romans 5", "Romans 8"]`
2. All three chapters fetched concurrently on `.task` (not sequentially)
3. **Reading phase (chapter 0):** Romans 3 displayed verse-by-verse, "Next" button
4. **Chapter quiz (chapter 0, iOS 26+ only):** 1-2 generated comprehension questions
5. **Reading phase (chapter 1):** Romans 5, same pattern
6. **Chapter quiz (chapter 1, iOS 26+ only):** comprehension check
7. **Reading phase (chapter 2):** Romans 8, same pattern
8. **Chapter quiz (chapter 2, iOS 26+ only):** comprehension check
9. **Teaching phase:** `lesson.teaching` displayed as commentary/context, "Start Challenge" button
10. **Quiz phase:** existing hand-written questions via `QuizQuestionCard`
11. **Results phase:** same XP calculation and score ring

### Single-Chapter Lessons

For `"Psalm 23"`, the parser returns one item. Flow: read one chapter → teaching → quiz → results. Functionally identical to today's working lessons, just with teaching moved after reading.

### Chapter Navigation

- Progress indicator shows current chapter position (e.g., "Chapter 2 of 3")
- "Next" button advances to the next chapter (or to chapter quiz on iOS 26+)
- No back navigation — read forward only (simplicity)

### Error Handling

- If a chapter fetch fails: show an inline error with a "Retry" button for that chapter. Do NOT fall back to `lesson.teaching`.
- If all chapters fail (no network): show a full-screen error with retry. The user cannot proceed to the quiz without reading.
- `lesson.teaching` is NEVER displayed as a substitute for scripture under any circumstance.

### Concurrent Fetching

All chapters are fetched concurrently when the view loads (`TaskGroup` or parallel `async let`). Results are stored in an array indexed by chapter position. Each chapter's loading state is tracked independently so the user can start reading chapter 1 while chapter 3 is still loading.

## 3. Per-Chapter Comprehension Quizzes

**File:** `Anchored/Services/ChapterQuizGenerator.swift`

iOS 26+ only. After each chapter, generate 1-2 multiple-choice comprehension questions from the chapter text the user just read.

### Interface

```swift
@MainActor
final class ChapterQuizGenerator {
    /// Generate 1-2 comprehension questions for a Bible passage.
    /// Returns empty array on iOS < 26 or if generation fails.
    func generate(for passage: BiblePassage) async -> [QuizQuestion]
}
```

### Output

Returns `[QuizQuestion]` — the same struct used by hand-written questions. This means `QuizQuestionCard` works unchanged for both comprehension checks and the final quiz.

### Generation Details

- Prompt instructs the model to produce 1-2 simple factual questions about what happens in the chapter
- Each question has 4 options, a correct index, and a brief explanation
- Questions should be answerable by someone who read the chapter — not trick questions, not theological interpretation

### Display

- Uses the same `QuizQuestionCard` component
- Header says "Comprehension Check" (not "Question X of Y")
- No XP awarded for comprehension checks — XP comes from the final hand-written quiz only
- No combo tracking on comprehension checks

### Fallback (iOS < 26)

Skip comprehension checks entirely. Flow goes straight from one chapter to the next.

### Error Handling

If Foundation Models fails (model unavailable, bad output, timeout), skip the comprehension check silently and advance to the next chapter. Comprehension checks are an enhancement, not a gate.

## Files Changed

### New Files
- `Anchored/Services/ScriptureReferenceParser.swift` — pure parser
- `Anchored/Services/ChapterQuizGenerator.swift` — Foundation Models quiz generation

### Modified Files
- `Anchored/Features/Lesson/LessonView.swift` — chapter-paged reading flow, new phase model, concurrent multi-fetch, teaching as post-reading commentary, comprehension check integration

### Unchanged
- `Anchored/Services/BibleAPIService.swift` — still fetches one reference at a time
- `Anchored/Features/Quiz/QuizQuestionCard.swift` — reused for both comprehension and final quiz
- `Anchored/Content/TopicCatalog.swift` — `Lesson` struct unchanged
- `Anchored/Content/GeneratedData/TopicsCatalog+Generated.swift` — curriculum data unchanged
- `layer2/` — source JS and generator unchanged

## Verification Checklist

1. Single-chapter lessons (`"Psalm 23"`) work as before: read → teaching → quiz → results
2. Semicolon references (`"Romans 3; 5; 8"`) show three separate chapters with paging
3. Hyphenated ranges (`"Genesis 6-9"`) expand to four chapters with paging
4. Verse-level references (`"John 3:16-18"`) pass through and fetch correctly
5. Teaching text appears after all reading, before the quiz — never as a scripture substitute
6. Failed chapter fetch shows retry button, not teaching fallback
7. All chapters fetched concurrently (not sequentially)
8. Chapter progress indicator shows position (e.g., "Chapter 2 of 3")
9. (iOS 26+) Comprehension questions appear after each chapter
10. (iOS 26+) Comprehension questions use the same `QuizQuestionCard` component
11. (iOS 26+) No XP awarded for comprehension checks
12. (iOS < 26) Comprehension checks are skipped, chapters flow directly
13. (iOS 26+) Failed quiz generation skips silently to next chapter
14. Hand-written quiz questions still work in the final quiz phase
15. XP calculation unchanged (based on final quiz only)
16. `#Preview` macros render without crashes
