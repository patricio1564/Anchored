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
