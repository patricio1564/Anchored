import SwiftUI

struct QuizQuestionCard: View {
    let question: QuizQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let shuffleSeed: Int
    let topicTitle: String?

    let onAnswer: (_ wasCorrect: Bool, _ userAnswer: String) -> Void
    let onContinue: () -> Void

    init(
        question: QuizQuestion,
        questionIndex: Int,
        totalQuestions: Int,
        shuffleSeed: Int,
        topicTitle: String? = nil,
        onAnswer: @escaping (_ wasCorrect: Bool, _ userAnswer: String) -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.question = question
        self.questionIndex = questionIndex
        self.totalQuestions = totalQuestions
        self.shuffleSeed = shuffleSeed
        self.topicTitle = topicTitle
        self.onAnswer = onAnswer
        self.onContinue = onContinue
    }

    @State private var selectedDisplayIndex: Int? = nil
    @State private var hasAnswered = false

    private let letters = ["A", "B", "C", "D", "E", "F"]

    private var shuffled: (options: [String], correctDisplayIndex: Int) {
        var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(shuffleSeed)))
        let indexed = question.options.enumerated().map { ($0.offset, $0.element) }
        let shuffled = indexed.shuffled(using: &rng)
        let correct = shuffled.firstIndex { $0.0 == question.correctIndex } ?? 0
        return (shuffled.map(\.1), correct)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Question label
            Text("QUESTION \(questionIndex + 1) OF \(totalQuestions)")
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(AnchoredColors.coral)
            + Text(topicTitle.map { " \u{00B7} \($0.uppercased())" } ?? "")
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(AnchoredColors.coral)

            // Prompt
            Text(question.prompt)
                .font(.custom("Newsreader", size: 28).weight(.regular))
                .tracking(-0.28)
                .lineSpacing(2)
                .foregroundStyle(AnchoredColors.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
                .padding(.bottom, 24)

            // Options
            VStack(spacing: 10) {
                ForEach(Array(shuffled.options.enumerated()), id: \.offset) { i, text in
                    optionButton(text: text, displayIndex: i)
                }
            }

            if hasAnswered {
                explanationPanel
                    .padding(.top, 16)

                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.custom("Outfit", size: 15.5).weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AnchoredColors.gradientPrimary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
                    .shadow(color: AnchoredColors.coral.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Option button

    private func optionButton(text: String, displayIndex: Int) -> some View {
        let isSelected = selectedDisplayIndex == displayIndex
        let isCorrect = displayIndex == shuffled.correctDisplayIndex

        return Button {
            guard !hasAnswered else { return }
            selectedDisplayIndex = displayIndex
            hasAnswered = true
            let wasCorrect = (displayIndex == shuffled.correctDisplayIndex)
            onAnswer(wasCorrect, text)
        } label: {
            HStack(spacing: 14) {
                // Letter badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(letterBadgeFill(selected: isSelected && !hasAnswered, correct: isCorrect && hasAnswered, wrong: isSelected && hasAnswered && !isCorrect))
                        .frame(width: 30, height: 30)
                    Text(displayIndex < letters.count ? letters[displayIndex] : "")
                        .font(.custom("Newsreader", size: 16).weight(.semibold))
                        .foregroundStyle(letterTextColor(selected: isSelected, correct: isCorrect && hasAnswered, wrong: isSelected && hasAnswered && !isCorrect))
                }

                Text(text)
                    .font(.custom("Newsreader", size: 17).weight(.medium))
                    .foregroundStyle(optionTextColor(selected: isSelected && !hasAnswered, correct: isCorrect && hasAnswered, wrong: isSelected && hasAnswered && !isCorrect))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if hasAnswered {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AnchoredColors.success)
                            .transition(.scale.combined(with: .opacity))
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AnchoredColors.error)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(18)
            .background(optionBg(selected: isSelected && !hasAnswered, correct: isCorrect && hasAnswered, wrong: isSelected && hasAnswered && !isCorrect))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                Group {
                    if !(isSelected && !hasAnswered) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(optionBorder(correct: isCorrect && hasAnswered, wrong: isSelected && hasAnswered && !isCorrect), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: (isSelected && !hasAnswered) ? AnchoredColors.coral.opacity(0.3) : .clear,
                radius: 14, x: 0, y: 12
            )
        }
        .buttonStyle(.plain)
        .disabled(hasAnswered)
        .animation(.easeOut(duration: 0.18), value: hasAnswered)
    }

    // MARK: - Explanation

    private var explanationPanel: some View {
        let correct = selectedDisplayIndex == shuffled.correctDisplayIndex
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: correct ? "checkmark.circle.fill" : "lightbulb.fill")
                    .foregroundStyle(correct ? AnchoredColors.success : AnchoredColors.gold)
                Text(correct ? "Well done" : "Here\u{2019}s the context")
                    .font(.custom("Outfit", size: 13).weight(.semibold))
                    .foregroundStyle(correct ? AnchoredColors.success : AnchoredColors.gold)
            }
            Text(question.explanation)
                .font(.custom("Outfit", size: 13).weight(.medium))
                .lineSpacing(3)
                .foregroundStyle(AnchoredColors.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (correct ? AnchoredColors.success : AnchoredColors.gold).opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Styling helpers

    @ViewBuilder
    private func optionBg(selected: Bool, correct: Bool, wrong: Bool) -> some View {
        if selected {
            AnchoredColors.gradientPrimary
        } else if correct {
            AnchoredColors.success.opacity(0.12)
        } else if wrong {
            AnchoredColors.error.opacity(0.10)
        } else {
            AnchoredColors.glass
                .background(.ultraThinMaterial)
        }
    }

    private func optionBorder(correct: Bool, wrong: Bool) -> Color {
        if correct { return AnchoredColors.success }
        if wrong { return AnchoredColors.error.opacity(0.7) }
        return AnchoredColors.line
    }

    private func optionTextColor(selected: Bool, correct: Bool, wrong: Bool) -> Color {
        if selected { return .white }
        if correct { return AnchoredColors.success }
        if wrong { return AnchoredColors.error }
        return AnchoredColors.ink
    }

    private func letterBadgeFill(selected: Bool, correct: Bool, wrong: Bool) -> Color {
        if selected { return Color.white.opacity(0.25) }
        if correct { return AnchoredColors.success.opacity(0.15) }
        if wrong { return AnchoredColors.error.opacity(0.15) }
        return AnchoredColors.coral.opacity(0.08)
    }

    private func letterTextColor(selected: Bool, correct: Bool, wrong: Bool) -> Color {
        if selected { return .white }
        if correct { return AnchoredColors.success }
        if wrong { return AnchoredColors.error }
        return AnchoredColors.coral
    }
}

// MARK: - SeededGenerator

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

// MARK: - Preview

#Preview("Unanswered") {
    let sample = QuizQuestion(
        prompt: "On which day did God create the sun, moon, and stars?",
        options: ["First day", "Third day", "Fourth day", "Sixth day"],
        correctIndex: 2,
        explanation: "Genesis 1:14\u{2013}19 describes the creation of the sun, moon, and stars on the fourth day to mark seasons, days, and years."
    )
    QuizQuestionCard(
        question: sample,
        questionIndex: 0,
        totalQuestions: 3,
        shuffleSeed: 42,
        topicTitle: "The Exodus",
        onAnswer: { _, _ in },
        onContinue: {}
    )
    .padding(22)
    .appBackground()
}
