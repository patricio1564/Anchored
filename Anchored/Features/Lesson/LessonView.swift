// ────────────────────────────────────────────────────────────────────────────
// LessonView.swift
//
// The heart of the learning flow. A three-phase screen:
//
//   1. READING — Teaching prose + key verse + "Start Challenge" CTA.
//   2. QUIZ    — One QuizQuestionCard at a time with a live combo badge.
//   3. RESULTS — Animated score ring, XP breakdown, wrong-answer review,
//                and a "Done" button that pops back to the topic.
//
// Integration points:
//   • Constructed with a Topic + Lesson (Hashable) via NavigationStack route.
//   • Uses @Environment(StreakManager.self) to award XP and check in.
//     StreakManager is constructed per-screen in parent views (.task), so we
//     expect it to already be in the environment by the time this view runs.
//   • Writes a LessonProgress row on completion. lessonId is @Attribute(.unique),
//     so retakes UPDATE the existing row — never insert a duplicate. Scores
//     only improve (we keep the best).
//
// XP math (matches Base44 reference):
//   • +10 per correct answer
//   • +5 combo bonus for each correct answer that extends a streak of 3+
//   • +50 perfect-score bonus
//   • +25 first-time-completion bonus (only on the first time the lesson
//     transitions to completed = true)
//
// All XP is summed locally and awarded in ONE call to StreakManager.awardXP
// at the end. StreakManager's checkIn() is also called once here so a
// completed lesson counts toward the daily streak.
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

    // We need to know if this lesson was already completed BEFORE this
    // attempt so we can decide whether to award the first-completion bonus.
    // We don't use @Query here because we only need a one-shot read at launch.
    @State private var priorProgress: LessonProgress? = nil

    // MARK: - Scripture fetch

    @AppStorage("preferredBibleTranslation") private var preferredTranslation: BibleTranslation = .web
    @State private var scripturePassage: BiblePassage?
    @State private var scriptureLoading = false

    // MARK: - Flow state

    private enum Phase { case reading, quiz, results }
    @State private var phase: Phase = .reading

    @State private var currentIndex = 0
    @State private var combo = 0
    @State private var answers: [AnswerRecord] = []   // one per question, in original order

    /// What was earned this session. Computed at results time.
    @State private var earnedXP = 0

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch phase {
                case .reading: readingPhase
                case .quiz:    quizPhase
                case .results: resultsPhase
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
            await loadScripture()
        }
    }

    // ────────────────────────────────────────────────────────────────────
    // MARK: - Phase 1: Reading
    // ────────────────────────────────────────────────────────────────────

    private var readingPhase: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scripture reference pill.
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                Text(lesson.scripture)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundStyle(AnchoredColors.amber)

            // Fetched Bible passage — falls back to lesson.teaching if offline.
            VStack(alignment: .leading, spacing: 10) {
                Text("Scripture")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AnchoredColors.amber)
                    .textCase(.uppercase)

                if scriptureLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                } else if let passage = scripturePassage {
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
                } else {
                    Text(lesson.teaching)
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.navy)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .cardSurface(padding: 16)

            // Key verse pull-quote.
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

            // Start button.
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
    // MARK: - Phase 2: Quiz
    // ────────────────────────────────────────────────────────────────────

    private var quizPhase: some View {
        VStack(alignment: .leading, spacing: 16) {
            if combo >= 2 {
                comboBadge
            }

            // One question at a time. The .id() modifier forces a fresh
            // QuizQuestionCard (and fresh local state) per question.
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
    // MARK: - Phase 3: Results
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
    // MARK: - Handlers
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

    /// Compute XP, persist the LessonProgress row, check in the streak,
    /// and flip to the results screen.
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

    /// Walk the answers list in order to compute combo bonuses so the
    /// total matches what the user saw during the quiz.
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
    // MARK: - Persistence
    // ────────────────────────────────────────────────────────────────────

    /// Load the pre-existing progress row once, before the user starts
    /// the quiz. This tells us whether to award the first-completion
    /// bonus later.
    private func loadScripture() async {
        scriptureLoading = true
        let translation = (preferredTranslation.isFree || premiumManager.isPremium)
            ? preferredTranslation : .web
        scripturePassage = try? await BibleAPIService.shared.fetch(
            reference: lesson.scripture,
            translation: translation
        )
        scriptureLoading = false
    }

    private func loadPriorProgress() {
        let lessonId = lesson.id
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.lessonId == lessonId }
        )
        priorProgress = try? modelContext.fetch(descriptor).first
    }

    /// Insert or update the LessonProgress row. lessonId is unique, so
    /// on retake we MUST fetch-and-mutate rather than insert a duplicate.
    /// Score is monotonic — we never regress the best score.
    private func persistProgress(xp: Int) {
        let lessonId = lesson.id
        let topicId = topic.id
        let newScore = scorePercent

        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.lessonId == lessonId }
        )

        do {
            if let existing = try modelContext.fetch(descriptor).first {
                // Retake: update in place. Keep best score.
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
//
// One entry per answered question. Kept in the order they were answered
// so we can recompute combo bonuses deterministically at results time.
// ────────────────────────────────────────────────────────────────────────────

private struct AnswerRecord {
    let question: QuizQuestion
    let userAnswer: String
    let correctAnswer: String
    let wasCorrect: Bool
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - ReviewCard
//
// Renders one missed question with the user's (wrong) answer and the
// correct answer, plus the explanation text.
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
