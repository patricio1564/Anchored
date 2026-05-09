import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Environment

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext

    // MARK: - Local state

    @State private var streak: StreakManager?
    @State private var dailyVerse: DailyVerse = DailyVerses.today()
    @State private var remoteVerseText: String?
    @State private var completedLessonsCount: Int = 0
    @State private var continueTopic: Topic?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                heroVerseCard
                statsRow
                progressCard
                Spacer(minLength: 40)
            }
            .padding(.top, 58)
            .screenPadding()
        }
        .appBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await bootstrap()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(greeting),")
                    .font(.custom("Newsreader", size: 13).weight(.regular).italic())
                    .foregroundStyle(AnchoredColors.inkSoft)
                Text(displayName)
                    .font(.custom("Newsreader", size: 30).weight(.regular))
                    .tracking(-0.6)
                    .foregroundStyle(AnchoredColors.ink)
            }
            Spacer()
            if let streak, streak.currentStreak > 0 {
                streakBadge(days: streak.currentStreak)
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: - Hero Verse Card

    private var heroVerseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AnchoredColors.coral)
                Text("VERSE OF THE DAY")
                    .font(.custom("Outfit", size: 11).weight(.semibold))
                    .tracking(0.44)
                    .textCase(.uppercase)
                    .foregroundStyle(AnchoredColors.coral)
            }

            Text(remoteVerseText ?? dailyVerse.text)
                .font(.custom("Newsreader", size: 19).weight(.regular).italic())
                .lineSpacing(7)
                .foregroundStyle(AnchoredColors.ink)

            Text("— \(dailyVerse.reference.uppercased())")
                .font(.custom("Outfit", size: 12).weight(.semibold))
                .tracking(0.48)
                .foregroundStyle(AnchoredColors.coral)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color.white.opacity(0.9), AnchoredColors.coralSoft.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Decorative sun glow top-right
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AnchoredColors.gold.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .offset(x: 60, y: -50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AnchoredColors.coralSoft, lineWidth: 1)
        )
    }

    // MARK: - Stats Row (3-up grid)

    private var statsRow: some View {
        HStack(spacing: 8) {
            statTile(
                icon: "flame.fill",
                tint: AnchoredColors.coral,
                value: "\(streak?.currentStreak ?? 0)",
                label: "Streak"
            )
            statTile(
                icon: "star.fill",
                tint: AnchoredColors.gold,
                value: "\(streak?.totalXP ?? 0)",
                label: "Total XP"
            )
            statTile(
                icon: "book.fill",
                tint: AnchoredColors.blue,
                value: "\(completedLessonsCount)",
                label: "Lessons"
            )
        }
    }

    // MARK: - Progress Card ("Your journey")

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your journey")
                    .font(.custom("Newsreader", size: 18).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                Spacer()
                if let streak {
                    Text(streak.levelTitle.uppercased())
                        .font(.custom("Outfit", size: 11).weight(.bold))
                        .tracking(0.66)
                        .foregroundStyle(AnchoredColors.coral)
                }
            }
            .padding(.bottom, 10)

            if let streak {
                HStack {
                    Text("Level \(streak.level)")
                        .font(.custom("Outfit", size: 13).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                    Spacer()
                    Text("\(streak.xpInCurrentLevel) / \(streak.xpForCurrentLevel) XP")
                        .font(.custom("Outfit", size: 12).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                        .monospacedDigit()
                }
                .padding(.bottom, 8)

                // XP track
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AnchoredColors.lineSoft)
                            .frame(height: 6)
                        Capsule()
                            .fill(AnchoredColors.gradientPrimary)
                            .frame(
                                width: geo.size.width * CGFloat(streak.xpInCurrentLevel) / CGFloat(max(streak.xpForCurrentLevel, 1)),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
                .clipShape(Capsule())
                .padding(.bottom, 16)
            }

            // Continue learning row
            if let continueTopic {
                NavigationLink(value: continueTopic) {
                    continueRow(for: continueTopic)
                }
                .buttonStyle(.plain)
            } else {
                Text("Start a topic in Learn to begin your journey.")
                    .font(.custom("Outfit", size: 13).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
            }
        }
        .glassCard(padding: 20, cornerRadius: 22)
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
        .navigationDestination(for: LessonDestination.self) { destination in
            LessonView(topic: destination.topic, lesson: destination.lesson)
        }
    }

    // MARK: - Sub-components

    private func streakBadge(days: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundStyle(AnchoredColors.coral)
            Text("\(days)")
                .font(.custom("Outfit", size: 13).weight(.bold))
                .foregroundStyle(AnchoredColors.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(AnchoredColors.coralSoft, lineWidth: 1)
        )
        .shadow(color: AnchoredColors.coral.opacity(0.15), radius: 6, x: 0, y: 4)
    }

    private func statTile(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon square
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(tint.opacity(0.13))
                    .frame(width: 24, height: 24)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(tint)
            }
            .padding(.bottom, 8)

            Text(value)
                .font(.custom("Newsreader", size: 24).weight(.medium))
                .monospacedDigit()
                .foregroundStyle(AnchoredColors.ink)

            Text(label)
                .font(.custom("Outfit", size: 11).weight(.medium))
                .foregroundStyle(AnchoredColors.inkSoft)
                .padding(.top, 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: 14, cornerRadius: 18)
    }

    private func continueRow(for topic: Topic) -> some View {
        HStack(spacing: 12) {
            // Topic gradient tile
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AnchoredColors.blue, AnchoredColors.lilac],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Continue")
                    .font(.custom("Outfit", size: 11.5).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                Text(topic.title)
                    .font(.custom("Newsreader", size: 16).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(AnchoredColors.inkMute)
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Data loading

    private func bootstrap() async {
        if streak == nil {
            let userId = authManager.currentUserId ?? "local-user"
            streak = StreakManager(modelContext: modelContext, userId: userId)
        }
        streak?.checkIn()
        refreshLessonCounts()
        refreshContinueTopic()
        await loadDailyVerseText()
    }

    private func refreshLessonCounts() {
        let descriptor = FetchDescriptor<LessonProgress>(
            predicate: #Predicate<LessonProgress> { $0.completed }
        )
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        completedLessonsCount = count
    }

    private func refreshContinueTopic() {
        let descriptor = FetchDescriptor<LessonProgress>()
        let completed = (try? modelContext.fetch(descriptor)) ?? []
        let completedIDs = Set(completed.filter(\.completed).map(\.lessonId))
        let next = TopicsCatalog.all.first { topic in
            topic.lessons.contains { !completedIDs.contains($0.id) }
        }
        continueTopic = next ?? TopicsCatalog.all.first
    }

    private func loadDailyVerseText() async {
        let translation = preferredTranslation()
        do {
            let passage = try await BibleAPIService.shared.fetch(
                reference: dailyVerse.reference,
                translation: translation
            )
            let cleaned = passage.text.trimmingCharacters(in: .whitespacesAndNewlines)
            await MainActor.run { self.remoteVerseText = cleaned }
        } catch {
            // Fall through: curated WEB text is already showing
        }
    }

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
