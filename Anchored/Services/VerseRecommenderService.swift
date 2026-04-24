// ────────────────────────────────────────────────────────────────────────────
// VerseRecommenderService.swift
//
// The Verse Recommender takes a user's free-text emotional prompt and
// returns 3-5 scripture passages with pastoral explanation and a
// first-person prayer per verse.
//
// ─────────────────────── PRIMARY: Foundation Models ─────────────────────────
//
// On iOS 26.0+ we use Apple's on-device Foundation Models framework.
// This keeps every query local to the device — no API keys in the
// binary, no personal emotional content sent to a server, no cost per
// request. The @Generable macro lets us declare the response schema
// once and Swift handles the decoding.
//
// We gate availability TWO ways:
//   1. #if canImport(FoundationModels) — protects builds on older SDKs
//      where the framework doesn't exist at compile time.
//   2. @available(iOS 26.0, *) + runtime #available — protects runtime
//      on devices that shipped with older iOS.
//
// ─────────────────────── FALLBACK: FeelingMap ──────────────────────────────
//
// When Foundation Models isn't available OR the session fails (model
// loading issue, unusual input, timeout), we fall through to the
// hand-curated FeelingMap content. The fallback returns the same
// VerseRecommendation shape so the view doesn't need to branch.
//
// This means the feature works offline, works on older devices, and
// gracefully degrades — the user never sees an error screen for the
// recommender. They see curated content instead.
// ────────────────────────────────────────────────────────────────────────────

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Service
// ─────────────────────────────────────────────────────────────────────────────

/// Async facade. Callers pass a free-text query and get back a
/// VerseRecommendation. They don't need to know whether the result came
/// from the model or the curated fallback.
@MainActor
final class VerseRecommenderService {

    static let shared = VerseRecommenderService()
    private init() {}

    /// The one public entry point. Always returns a result — fallback
    /// ensures we never throw to the UI.
    func recommend(for userText: String) async -> VerseRecommendation {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty / trivially short input — don't bother the model. Route
        // directly to generic comfort.
        guard trimmed.count >= 3 else {
            return FeelingMap.genericComfort()
        }

        // Primary path: Foundation Models, iOS 26.0+.
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if let modelResult = await runFoundationModels(prompt: trimmed) {
                return modelResult
            }
        }
        #endif

        // Fallback: keyword-match against FeelingMap, then generic if no match.
        if let feeling = FeelingMap.match(trimmed) {
            return FeelingMap.recommendation(for: feeling)
        }
        return FeelingMap.genericComfort()
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Foundation Models primary path
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(FoundationModels)

/// The schema the model is asked to produce. @Generable + @Guide hints
/// steer the structured output so we can decode it reliably.
@available(iOS 26.0, *)
@Generable
private struct GeneratedRecommendation {
    @Guide(description: "A 1-2 sentence compassionate opening acknowledging what the person shared.")
    let summary: String

    @Guide(description: "Three to five Bible verses that speak to the user's situation.")
    let verses: [GeneratedVerse]

    @Guide(description: "A brief warm closing sentence of encouragement.")
    let closingEncouragement: String
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedVerse {
    @Guide(description: "The scripture reference, e.g. 'Philippians 4:6-7'.")
    let reference: String

    @Guide(description: "The verse text. Use a public-domain translation (WEB, KJV, ASV).")
    let text: String

    @Guide(description: "1-2 sentences on why this verse speaks to the person's situation.")
    let explanation: String

    @Guide(description: "A short first-person prayer (2-4 sentences) the person can pray, speaking directly to God.")
    let prayer: String
}

@available(iOS 26.0, *)
extension VerseRecommenderService {

    /// Try the Foundation Models path. Returns nil on any failure — the
    /// caller will fall through to the curated fallback.
    func runFoundationModels(prompt userPrompt: String) async -> VerseRecommendation? {
        let instructions = """
        You are a warm, pastoral Bible recommender. When someone shares how they \
        are feeling, you respond with three to five scripture passages from the \
        Christian Bible (Old and New Testament) that speak directly and \
        compassionately to their situation. Each verse comes with a short \
        explanation of why it applies and a first-person prayer the person can \
        pray to God. Be specific, not generic. Be pastoral, not preachy.
        """

        let fullPrompt = """
        A person is feeling or going through the following: "\(userPrompt)"

        Please find 3-5 Bible verses that speak to this situation. Be compassionate \
        and specific. Choose verses that are genuinely comforting and applicable.
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            // Race the model against an 8-second timeout. On simulator the
            // on-device LLM isn't available and hangs rather than throwing,
            // so without a timeout the sheet spinner would spin forever.
            let result: VerseRecommendation? = try await withThrowingTaskGroup(
                of: VerseRecommendation?.self
            ) { group in
                group.addTask {
                    let response = try await session.respond(
                        to: fullPrompt,
                        generating: GeneratedRecommendation.self
                    )
                    return response.content.toRecommendation()
                }
                group.addTask {
                    try await Task.sleep(for: .seconds(8))
                    throw CancellationError()
                }
                let value = try await group.next()
                group.cancelAll()
                return value ?? nil
            }
            return result
        } catch {
            // Timeout or model error — caller falls through to FeelingMap.
            return nil
        }
    }
}

@available(iOS 26.0, *)
private extension GeneratedRecommendation {
    /// Convert the model's @Generable output into the public type.
    func toRecommendation() -> VerseRecommendation {
        VerseRecommendation(
            summary: summary,
            verses: verses.map { v in
                RecommendedVerse(
                    reference: v.reference,
                    text: v.text,
                    explanation: v.explanation,
                    prayer: v.prayer
                )
            },
            closingEncouragement: closingEncouragement
        )
    }
}

#endif
