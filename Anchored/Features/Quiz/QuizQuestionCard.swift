// ────────────────────────────────────────────────────────────────────────────
// QuizQuestionCard.swift
//
// A single multiple-choice question with color-coded feedback and an
// explanation panel shown after the user answers.
//
// Usage:
//     QuizQuestionCard(
//         question: lesson.questions[idx],
//         questionIndex: idx,
//         totalQuestions: lesson.questions.count,
//         shuffleSeed: lesson.id.hashValue &+ idx,  // stable during session
//         onAnswer: { wasCorrect, userAnswerText in ... },
//         onContinue: { ... }
//     )
//
// Why the card owns its own answered-state: it keeps the parent (LessonView)
// from having to reset a bunch of flags between questions. When the parent
// swaps in a new question by id, a new Card is created fresh.
// ────────────────────────────────────────────────────────────────────────────

import SwiftUI

struct QuizQuestionCard: View {
    let question: QuizQuestion
    let questionIndex: Int
    let totalQuestions: Int
    /// Stable seed so the shuffle doesn't change between body re-evaluations.
    /// Pass something derived from (lesson.id, questionIndex).
    let shuffleSeed: Int

    /// Called once when the user picks an option. `wasCorrect` tells the
    /// parent whether to bump the score and combo; `userAnswer` is the
    /// option text the user picked (useful for review screens).
    let onAnswer: (_ wasCorrect: Bool, _ userAnswer: String) -> Void

    /// Called when the user taps Continue after seeing the explanation.
    let onContinue: () -> Void

    // MARK: - Local state

    @State private var selectedDisplayIndex: Int? = nil
    @State private var hasAnswered = false

    // MARK: - Shuffle (computed once per init via the seed)

    /// The options in display order, and the display-order index of the
    /// correct option. Computed from the seed so it's stable across
    /// SwiftUI re-renders in the same session but varies by question.
    private var shuffled: (options: [String], correctDisplayIndex: Int) {
        var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(shuffleSeed)))
        let indexed = question.options.enumerated().map { ($0.offset, $0.element) }
        let shuffled = indexed.shuffled(using: &rng)
        let correct = shuffled.firstIndex { $0.0 == question.correctIndex } ?? 0
        return (shuffled.map(\.1), correct)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            progressHeader
            prompt
            options
            if hasAnswered {
                explanationPanel
                continueButton
            }
        }
    }

    // MARK: - Subviews

    private var progressHeader: some View {
        HStack {
            Text("Question \(questionIndex + 1) of \(totalQuestions)")
                .font(.caption.weight(.medium))
                .foregroundStyle(AnchoredColors.muted)
                .textCase(.uppercase)

            Spacer()

            // Progress dots — filled for completed, half for current, dim for future.
            HStack(spacing: 4) {
                ForEach(0..<totalQuestions, id: \.self) { i in
                    Capsule()
                        .fill(dotColor(for: i))
                        .frame(width: 18, height: 4)
                }
            }
        }
    }

    private var prompt: some View {
        Text(question.prompt)
            .anchoredStyle(.h3)
            .foregroundStyle(AnchoredColors.navy)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var options: some View {
        VStack(spacing: 10) {
            ForEach(Array(shuffled.options.enumerated()), id: \.offset) { i, text in
                optionButton(text: text, displayIndex: i)
            }
        }
    }

    private func optionButton(text: String, displayIndex: Int) -> some View {
        Button {
            guard !hasAnswered else { return }
            selectedDisplayIndex = displayIndex
            hasAnswered = true
            let wasCorrect = (displayIndex == shuffled.correctDisplayIndex)
            onAnswer(wasCorrect, text)
        } label: {
            HStack(spacing: 12) {
                Text(text)
                    .font(.system(.body, weight: .medium))
                    .foregroundStyle(optionTextColor(for: displayIndex))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if hasAnswered {
                    Image(systemName: optionTrailingIcon(for: displayIndex))
                        .foregroundStyle(optionIconColor(for: displayIndex))
                        .font(.system(size: 18, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(optionBackground(for: displayIndex), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(optionBorder(for: displayIndex), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(hasAnswered)
        .animation(.easeInOut(duration: 0.2), value: hasAnswered)
    }

    private var explanationPanel: some View {
        let correct = selectedDisplayIndex == shuffled.correctDisplayIndex
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: correct ? "checkmark.circle.fill" : "lightbulb.fill")
                    .foregroundStyle(correct ? .green : AnchoredColors.amber)
                Text(correct ? "Well done" : "Here's the context")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(correct ? .green : AnchoredColors.amber)
            }
            Text(question.explanation)
                .font(.callout)
                .foregroundStyle(AnchoredColors.navy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (correct ? Color.green : AnchoredColors.amber).opacity(0.08),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var continueButton: some View {
        Button {
            onContinue()
        } label: {
            HStack(spacing: 8) {
                Text(questionIndex + 1 == totalQuestions ? "See Results" : "Continue")
                    .font(.system(.body, weight: .semibold))
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AnchoredColors.amber, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Styling helpers

    private func dotColor(for index: Int) -> Color {
        if index < questionIndex { return AnchoredColors.amber }
        if index == questionIndex { return AnchoredColors.amber.opacity(0.5) }
        return AnchoredColors.muted.opacity(0.3)
    }

    private func optionBackground(for index: Int) -> Color {
        guard hasAnswered else { return AnchoredColors.parchment }
        if index == shuffled.correctDisplayIndex {
            return Color.green.opacity(0.12)
        }
        if index == selectedDisplayIndex {
            return Color.red.opacity(0.10)
        }
        return AnchoredColors.parchment.opacity(0.6)
    }

    private func optionBorder(for index: Int) -> Color {
        guard hasAnswered else { return AnchoredColors.muted.opacity(0.25) }
        if index == shuffled.correctDisplayIndex { return .green }
        if index == selectedDisplayIndex { return .red.opacity(0.7) }
        return AnchoredColors.muted.opacity(0.15)
    }

    private func optionTextColor(for index: Int) -> Color {
        guard hasAnswered else { return AnchoredColors.navy }
        if index == shuffled.correctDisplayIndex { return .green }
        if index == selectedDisplayIndex { return .red }
        return AnchoredColors.navy.opacity(0.5)
    }

    private func optionTrailingIcon(for index: Int) -> String {
        if index == shuffled.correctDisplayIndex { return "checkmark.circle.fill" }
        if index == selectedDisplayIndex { return "xmark.circle.fill" }
        return ""
    }

    private func optionIconColor(for index: Int) -> Color {
        if index == shuffled.correctDisplayIndex { return .green }
        if index == selectedDisplayIndex { return .red }
        return .clear
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - SeededGenerator
//
// Tiny deterministic RNG so `[Array].shuffled(using:)` produces the same
// order every time for a given seed. Splitmix64 — well-known, one-liner,
// good enough for shuffling 4 options.
// ────────────────────────────────────────────────────────────────────────────

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Preview
// ────────────────────────────────────────────────────────────────────────────

#Preview("Unanswered") {
    let sample = QuizQuestion(
        prompt: "On which day did God create the sun, moon, and stars?",
        options: ["First day", "Third day", "Fourth day", "Sixth day"],
        correctIndex: 2,
        explanation: "Genesis 1:14–19 describes the creation of the sun, moon, and stars on the fourth day to mark seasons, days, and years."
    )
    return QuizQuestionCard(
        question: sample,
        questionIndex: 0,
        totalQuestions: 3,
        shuffleSeed: 42,
        onAnswer: { _, _ in },
        onContinue: {}
    )
    .padding()
    .background(AnchoredColors.parchment)
}
