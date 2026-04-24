//
//  HomeView.swift
//  Anchored
//
//  The landing tab. Greeting + streak badge at the top, the Daily Verse
//  card, a 3-stat row (streak / XP / lessons), and a "Continue Your
//  Journey" card that deep-links into the next lesson.
//
//  ───── Architecture notes ─────
//  • StreakManager is constructed once in `.task` and held in @State so
//    it survives tab-switches without re-creating. The manager itself
//    is @Observable, so SwiftUI re-renders when its mirrored properties
//    change (see StreakManager.swift for the full "mirror" explanation).
//
//  • Daily verse loads via BibleAPIService on first appearance. If the
//    fetch fails we fall through to the curated WEB text from
//    DailyVerses — which means offline and API-outage days still show
//    something, they just show the hardcoded translation.
//
//  • Check-in happens exactly once per launch per day. The manager's
//    `checkIn()` is idempotent within a calendar day, so calling on
//    every appear is safe, but we only do it in `.task` for clarity.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Environment

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext

    // MARK: - Local state

    /// Streak manager. Built in `.task` because we need modelContext.
    @State private var streak: StreakManager?

    /// The daily verse reference (stable) + its text for the current
    /// translation. Starts with the curated WEB text and swaps to the
    /// API response once it loads.
    @State private var dailyVerse: DailyVerse = DailyVerses.today()

    /// Loaded translation text. Nil means "show curated DailyVerse.text
    /// as-is" (no network hit yet, or the fetch failed).
    @State private var remoteVerseText: String?

    /// Count of completed lessons — used in the stats row. Queried
    /// once per appearance.
    @State private var completedLessonsCount: Int = 0

    /// Continue-your-journey target: the first topic with any incomplete
    /// lessons, or the first topic overall if everything's done/empty.
    @State private var continueTopic: Topic?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                dailyVerseCard
                statsRow
                continueJourneyCard
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
            .screenPadding()
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await bootstrap()
        }
    }

    // MARK: - Sections

    /// Greeting with the user's name (from AuthManager state) and a flame
    /// badge if their streak is active.
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                Text(displayName)
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.navy)
            }
            Spacer()
            if let streak, streak.currentStreak > 0 {
                streakBadge(days: streak.currentStreak)
            }
        }
    }

    /// The Daily Verse card — amber-tinted, large italic scripture with
    /// reference. Updates text when the remote fetch lands.
    private var dailyVerseCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(AnchoredColors.amber)
                Text("Verse of the Day")
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.amber)
            }

            Text(remoteVerseText ?? dailyVerse.text)
                .anchoredStyle(.scripture)
                .foregroundStyle(AnchoredColors.navy)

            Text("— \(dailyVerse.reference)")
                .anchoredStyle(.reference)
                .foregroundStyle(AnchoredColors.navy.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .amberCard()
    }

    /// Three compact stat tiles side-by-side: streak, XP, completed.
    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(
                icon: "flame.fill",
                tint: AnchoredColors.streak,
                value: "\(streak?.currentStreak ?? 0)",
                label: "Day streak"
            )
            statTile(
                icon: "star.fill",
                tint: AnchoredColors.amber,
                value: "\(streak?.totalXP ?? 0)",
                label: "Total XP"
            )
            statTile(
                icon: "book.fill",
                tint: AnchoredColors.navy,
                value: "\(completedLessonsCount)",
                label: "Lessons"
            )
        }
    }

    /// Continue-your-journey card. Shows the next topic with incomplete
    /// lessons and an XP progress bar toward the next level.
    private var continueJourneyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Journey")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                if let streak {
                    Text(streak.levelTitle)
                        .anchoredStyle(.label)
                        .foregroundStyle(AnchoredColors.amber)
                }
            }

            // XP progress toward next level
            if let streak {
                xpBar(
                    current: streak.xpInCurrentLevel,
                    total: streak.xpForCurrentLevel,
                    level: streak.level
                )
            }

            Divider().background(AnchoredColors.border)

            // Continue target
            if let continueTopic {
                NavigationLink(value: continueTopic) {
                    continueRow(for: continueTopic)
                }
                .buttonStyle(.plain)
            } else {
                Text("Load up a topic in Learn to start your journey.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
            }
        }
        .cardSurface(padding: 20)
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
        .navigationDestination(for: LessonDestination.self) { destination in
            LessonView(topic: destination.topic, lesson: destination.lesson)
        }
    }

    // MARK: - Sub-components

    private func streakBadge(days: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
            Text("\(days)")
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AnchoredColors.streak.opacity(0.15))
        .foregroundStyle(AnchoredColors.streak)
        .clipShape(Capsule())
    }

    private func statTile(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .font(.system(size: 16))
            Text(value)
                .anchoredStyle(.xpDigit)
                .foregroundStyle(AnchoredColors.navy)
            Text(label)
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 14)
    }

    private func xpBar(current: Int, total: Int, level: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Level \(level)")
                    .anchoredStyle(.bodyMd)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Text("\(current) / \(total) XP")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
            // SwiftUI's native progress view — respects the tint we set
            // at the app level so we get amber fill automatically.
            ProgressView(value: Double(current), total: Double(total))
                .progressViewStyle(.linear)
                .tint(AnchoredColors.amber)
        }
    }

    private func continueRow(for topic: Topic) -> some View {
        HStack(spacing: 14) {
            // Topic gradient chip
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(topic.gradient.linearGradient)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(topic.icon)
                        .font(.system(size: 22))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Continue learning")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                Text(topic.title)
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.navy)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AnchoredColors.muted)
        }
    }

    // MARK: - Data loading

    /// One-time setup: build the streak manager, check in, load the daily
    /// verse from the API, and compute the "continue" target.
    private func bootstrap() async {
        // Build the StreakManager once and seed check-in for today. This
        // is idempotent so calling in `.task` on every appearance is safe.
        if streak == nil {
            let userId = authManager.currentUserId ?? "local-user"
            streak = StreakManager(modelContext: modelContext, userId: userId)
        }
        streak?.checkIn()

        // Count completed lessons (for the stat tile).
        refreshLessonCounts()

        // Pick the continue target.
        refreshContinueTopic()

        // Fetch the daily verse text from the API so we respect the
        // user's translation preference (WEB default for free users).
        await loadDailyVerseText()
    }

    /// Pull the count of completed LessonProgress rows. Kept as a
    /// separate step so we can re-run it after a lesson finishes
    /// (which this view doesn't do yet, but a notification-driven
    /// refresh is trivial to add).
    private func refreshLessonCounts() {
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.completed }
        )
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        completedLessonsCount = count
    }

    /// Choose the next topic that has any not-yet-completed lessons.
    /// Falls back to the first topic if everything's done.
    private func refreshContinueTopic() {
        let descriptor = FetchDescriptor<LessonProgress>()
        let completed = (try? modelContext.fetch(descriptor)) ?? []
        let completedIDs = Set(completed.filter(\.completed).map(\.lessonId))

        let next = TopicsCatalog.all.first { topic in
            topic.lessons.contains { !completedIDs.contains($0.id) }
        }
        continueTopic = next ?? TopicsCatalog.all.first
    }

    /// Fetch the verse text in the user's preferred translation. We
    /// don't block the UI — the curated WEB text is already shown and
    /// swaps in when the fetch returns.
    private func loadDailyVerseText() async {
        let translation = preferredTranslation()
        do {
            let passage = try await BibleAPIService.shared.fetch(
                reference: dailyVerse.reference,
                translation: translation
            )
            // Trim leading/trailing whitespace — bible-api responses
            // occasionally include footnote markers as newlines.
            let cleaned = passage.text.trimmingCharacters(in: .whitespacesAndNewlines)
            await MainActor.run { self.remoteVerseText = cleaned }
        } catch {
            // Silent fall-through: the curated WEB text is already on
            // screen, so the user sees scripture either way.
        }
    }

    /// Look up the user's preferred translation from their settings row.
    /// Defaults to WEB if nothing's saved or the value is unknown.
    private func preferredTranslation() -> BibleTranslation {
        let descriptor = FetchDescriptor<UserSettings>()
        guard let settings = (try? modelContext.fetch(descriptor))?.first,
              let translation = BibleTranslation(rawValue: settings.preferredTranslation)
        else { return .web }
        return translation
    }

    // MARK: - Derived display values

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Peace be with you"
        }
    }

    private var displayName: String {
        if case let .signedIn(_, name) = authManager.state, let name, !name.isEmpty {
            return name
        }
        return "Friend"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { HomeView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}
