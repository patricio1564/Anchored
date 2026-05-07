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
                    },
                    onContinue: {
                        let questions = comprehensionQuestions[chapterIndex] ?? []
                        if comprehensionIndex + 1 < questions.count {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                comprehensionIndex += 1
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
        _ = streakManager.checkIn()

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
