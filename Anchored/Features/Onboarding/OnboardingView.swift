import SwiftUI
import SwiftData
import AuthenticationServices

struct OnboardingView: View {

    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext

    @State private var page: Int = 0

    // Page 1: Why
    @State private var selectedGoals: Set<String> = []

    // Page 2: Familiarity
    @State private var selectedExperience: String = ""

    // Page 3: Reminder
    @State private var notificationsAccepted: Bool = false
    @State private var reminderDate: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    // Page 4: Verse finder
    @State private var demoInput: String = ""
    @State private var demoPhase: RecommenderDemoPhase = .idle
    @FocusState private var isFeelingFieldFocused: Bool
    enum RecommenderDemoPhase { case idle, loading, done(VerseRecommendation) }

    // Pages 5-6: Prayer + Reward
    @State private var prayerText: String = ""
    @State private var prayerLoading: Bool = false
    @State private var didPray: Bool = false
    @State private var showSparkleBurst: Bool = false
    @State private var xpScale: CGFloat = 0.5

    // Page 7: Subscribe
    @State private var selectedPlan: PremiumManager.Plan = .yearly

    private let totalSteps = 7

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dawn background (gradient + glow)
            AnchoredColors.backgroundGradient.ignoresSafeArea()

            ZStack {
                RadialGradient(
                    colors: [AnchoredColors.coralSoft.opacity(0.56), .clear],
                    center: UnitPoint(x: 0.5, y: -0.1),
                    startRadius: 0, endRadius: 300
                )
                RadialGradient(
                    colors: [AnchoredColors.lilac.opacity(0.25), .clear],
                    center: UnitPoint(x: 1.0, y: 0.5),
                    startRadius: 0, endRadius: 250
                )
                RadialGradient(
                    colors: [AnchoredColors.blueSoft.opacity(0.50), .clear],
                    center: UnitPoint(x: 0.0, y: 0.9),
                    startRadius: 0, endRadius: 280
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Page content
            Group {
                switch page {
                case 0: welcomePage
                case 1: whyPage
                case 2: familiarityPage
                case 3: reminderPage
                case 4: verseFinderPage
                case 5: prayerPage
                case 6: rewardPage
                case 7: subscribePage
                case 8: signInPage
                default: EmptyView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: page)
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 01 Welcome
    // ────────────────────────────────────────────────────────────────

    private var welcomePage: some View {
        ZStack {
            VStack(spacing: 0) {
                BrandHeader()
                Spacer()
            }

            VStack(spacing: 14) {
                // Sun illustration
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AnchoredColors.gold, AnchoredColors.coral.opacity(0.4), AnchoredColors.coral.opacity(0)],
                                center: .center,
                                startRadius: 0, endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                    Circle()
                        .fill(AnchoredColors.gold)
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(AnchoredColors.coral, lineWidth: 1)
                        .frame(width: 120, height: 120)
                        .opacity(0.5)
                    Circle()
                        .stroke(AnchoredColors.lilac, lineWidth: 1)
                        .frame(width: 156, height: 156)
                        .opacity(0.4)
                }
                .padding(.bottom, 10)

                // Headline
                VStack(spacing: 0) {
                    Text("Every morning,")
                        .font(.custom("Newsreader", size: 38).weight(.regular))
                        .tracking(-0.76)
                    Text("new mercies.")
                        .font(.custom("Newsreader", size: 38).weight(.regular).italic())
                        .tracking(-0.76)
                        .foregroundStyle(AnchoredColors.coral)
                }
                .foregroundStyle(AnchoredColors.ink)
                .multilineTextAlignment(.center)
                .lineLimit(nil)

                Text("A bright, gentle way to read and reflect on Scripture — for beginners and lifelong learners.")
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 280)
            }
            .padding(.horizontal, 32)

            DawnBottomButton(label: "Begin the journey") {
                withAnimation { page = 1 }
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 02 Why
    // ────────────────────────────────────────────────────────────────

    private let reasons: [(id: String, label: String, icon: String, accent: Color)] = [
        ("faith",      "Grow in faith",       "heart.fill",          AnchoredColors.coral),
        ("reading",    "Read regularly",       "book.fill",           AnchoredColors.gold),
        ("knowledge",  "Deepen knowledge",     "lightbulb.fill",      AnchoredColors.blue),
        ("prayer",     "Strengthen prayer",    "hands.sparkles.fill", AnchoredColors.lilac),
        ("comfort",    "Find comfort",         "sun.max.fill",        AnchoredColors.coral),
        ("devotional", "Daily devotion",       "moon.fill",           AnchoredColors.gold),
    ]

    private var whyPage: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BrandHeader(step: 0, total: totalSteps)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 0) {
                            Text("What drew you ")
                                .font(.custom("Newsreader", size: 30).weight(.regular))
                                .tracking(-0.6)
                            Text("here?")
                                .font(.custom("Newsreader", size: 30).weight(.regular).italic())
                                .tracking(-0.6)
                                .foregroundStyle(AnchoredColors.coral)
                        }
                        .foregroundStyle(AnchoredColors.ink)

                        Text("Pick anything that resonates.")
                            .font(.custom("Outfit", size: 13.5))
                            .foregroundStyle(AnchoredColors.inkSoft)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 22)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(reasons, id: \.id) { reason in
                            SelectionTile(
                                label: reason.label,
                                icon: reason.icon,
                                accent: reason.accent,
                                selected: selectedGoals.contains(reason.id)
                            ) {
                                if selectedGoals.contains(reason.id) {
                                    selectedGoals.remove(reason.id)
                                } else {
                                    selectedGoals.insert(reason.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 120)
                }
            }

            DawnBottomButton(label: "Continue", disabled: selectedGoals.isEmpty) {
                withAnimation { page = 2 }
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 03 Familiarity
    // ────────────────────────────────────────────────────────────────

    private let experiences: [(id: String, title: String, subtitle: String)] = [
        ("new",      "New to the Bible",  "Just getting started"),
        ("some",     "Some familiarity",  "Read parts of it"),
        ("regular",  "Regular reader",    "I read often"),
        ("lifelong", "Lifelong student",  "Central to my life"),
    ]

    private var familiarityPage: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BrandHeader(step: 1, total: totalSteps)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text("How well do you ")
                                .font(.custom("Newsreader", size: 30).weight(.regular))
                                .tracking(-0.6)
                            Text("know it?")
                                .font(.custom("Newsreader", size: 30).weight(.regular).italic())
                                .tracking(-0.6)
                                .foregroundStyle(AnchoredColors.coral)
                        }
                        .foregroundStyle(AnchoredColors.ink)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 22)

                    VStack(spacing: 10) {
                        ForEach(experiences, id: \.id) { exp in
                            RadioRow(
                                title: exp.title,
                                subtitle: exp.subtitle,
                                selected: selectedExperience == exp.id
                            ) {
                                selectedExperience = exp.id
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 120)
                }
            }

            DawnBottomButton(label: "Continue", disabled: selectedExperience.isEmpty) {
                withAnimation { page = 3 }
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 04 Daily Reminder
    // ────────────────────────────────────────────────────────────────

    private var reminderPage: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 14) {
                    BrandHeader(step: 2, total: totalSteps)

                    // Info card
                    VStack(alignment: .leading, spacing: 14) {
                        // Gradient icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AnchoredColors.gradientPrimary)
                                .frame(width: 48, height: 48)
                                .shadow(color: AnchoredColors.coral.opacity(0.35), radius: 9, x: 0, y: 8)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 0) {
                                Text("One small ")
                                    .font(.custom("Newsreader", size: 22).weight(.regular))
                                Text("moment")
                                    .font(.custom("Newsreader", size: 22).weight(.regular).italic())
                                    .foregroundStyle(AnchoredColors.coral)
                                Text(", daily.")
                                    .font(.custom("Newsreader", size: 22).weight(.regular))
                            }
                            .foregroundStyle(AnchoredColors.ink)

                            Text("A gentle nudge to keep your habit alive. Adjust anytime in Settings.")
                                .font(.custom("Outfit", size: 13.5))
                                .foregroundStyle(AnchoredColors.inkSoft)
                                .lineSpacing(4)
                        }
                    }
                    .glassCard(padding: 22, cornerRadius: 24)
                    .padding(.horizontal, 24)

                    // Toggle + time picker card
                    VStack(spacing: 18) {
                        HStack {
                            Text("Daily reminder")
                                .font(.custom("Outfit", size: 15.5).weight(.semibold))
                                .foregroundStyle(AnchoredColors.ink)
                            Spacer()
                            DawnToggle(isOn: $notificationsAccepted)
                        }

                        if notificationsAccepted {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("REMINDER TIME")
                                    .font(.custom("Outfit", size: 11).weight(.semibold))
                                    .tracking(1.54)
                                    .foregroundStyle(AnchoredColors.inkSoft)

                                DatePicker(
                                    "",
                                    selection: $reminderDate,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(height: 130)
                                .frame(maxWidth: .infinity)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .glassCard(padding: 22, cornerRadius: 24)
                    .padding(.horizontal, 24)
                    .onChange(of: notificationsAccepted) { _, accepted in
                        if accepted {
                            Task { _ = await NotificationService.shared.requestAuthorization() }
                        }
                    }

                    Spacer(minLength: 120)
                }
            }

            DawnBottomButton(label: "Continue") {
                if notificationsAccepted {
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                    let hour = comps.hour ?? 8
                    let minute = comps.minute ?? 0
                    let row = ensureSettingsRow()
                    row.dailyReminderTime = String(format: "%02d:%02d", hour, minute)
                    row.notificationsEnabled = true
                    try? modelContext.save()
                    Task { _ = await NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute) }
                }
                Task { await generatePrayer() }
                withAnimation { page = 4 }
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 05 Verse Finder
    // ────────────────────────────────────────────────────────────────

    private var verseFinderPage: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BrandHeader(step: 3, total: totalSteps)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                    // Header with icon
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AnchoredColors.gradientCool)
                                .frame(width: 44, height: 44)
                                .shadow(color: AnchoredColors.lilac.opacity(0.35), radius: 9, x: 0, y: 8)
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                Text("A verse for ")
                                    .font(.custom("Newsreader", size: 22).weight(.regular))
                                Text("any moment")
                                    .font(.custom("Newsreader", size: 22).weight(.regular).italic())
                                    .foregroundStyle(AnchoredColors.coral)
                            }
                            .foregroundStyle(AnchoredColors.ink)

                            Text("Tell us what's on your heart.")
                                .font(.custom("Outfit", size: 13))
                                .foregroundStyle(AnchoredColors.inkSoft)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)

                    // Input field
                    VStack(spacing: 10) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $demoInput)
                                .focused($isFeelingFieldFocused)
                                .scrollContentBackground(.hidden)
                                .foregroundStyle(AnchoredColors.ink)
                                .font(.custom("Newsreader", size: 14.5).weight(.regular).italic())
                                .padding(14)
                                .frame(minHeight: 52, maxHeight: 52)
                                .background(AnchoredColors.glassStrong)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(AnchoredColors.line, lineWidth: 1)
                                )

                            if demoInput.isEmpty {
                                Text("\"I feel like I am being tested.\"")
                                    .font(.custom("Newsreader", size: 14.5).weight(.regular).italic())
                                    .foregroundStyle(AnchoredColors.inkMute)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Find button
                        DawnButton(
                            label: { if case .idle = demoPhase { return "Find another" }; return "Find another" }(),
                            primary: true,
                            icon: "sparkles",
                            disabled: demoInput.trimmingCharacters(in: .whitespacesAndNewlines).count < 3
                        ) {
                            isFeelingFieldFocused = false
                            Task { await runDemoRecommender() }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Verse result
                    if case .done(let rec) = demoPhase, let first = rec.verses.first {
                        VerseCard(
                            citation: first.reference,
                            verse: first.text,
                            reflection: "A reminder God isn't distant when things are hard — he is here, right now."
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 120)
                }
            }

            DawnBottomButton(label: "Continue") {
                isFeelingFieldFocused = false
                Task { await generatePrayer() }
                withAnimation { page = 5 }
            }
        }
    }

    @MainActor
    private func runDemoRecommender() async {
        let query = demoInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 3 else { return }
        withAnimation { demoPhase = .loading }
        let result = await VerseRecommenderService.shared.recommend(for: query)
        withAnimation { demoPhase = .done(result) }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 06 Prayer
    // ────────────────────────────────────────────────────────────────

    private var prayerPage: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    BrandHeader(step: 4, total: totalSteps)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Text("🙏").font(.system(size: 32))
                            Text("Let's Talk to God")
                                .font(.custom("Newsreader", size: 22).weight(.medium))
                                .foregroundStyle(AnchoredColors.ink)
                        }

                        if prayerLoading {
                            HStack(spacing: 12) {
                                ProgressView().tint(AnchoredColors.coral)
                                Text("Preparing a prayer for you...")
                                    .font(.custom("Outfit", size: 14.5))
                                    .foregroundStyle(AnchoredColors.inkSoft)
                            }
                            .padding(.vertical, 8)
                        } else if !prayerText.isEmpty {
                            Text(prayerText)
                                .font(.custom("Newsreader", size: 19).weight(.regular).italic())
                                .lineSpacing(7)
                                .foregroundStyle(AnchoredColors.ink)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Take a moment to pray this to the Lord.")
                                .font(.custom("Outfit", size: 14))
                                .foregroundStyle(AnchoredColors.inkSoft)
                        } else {
                            Text("A personal prayer will be prepared based on your verse.")
                                .font(.custom("Outfit", size: 14.5))
                                .foregroundStyle(AnchoredColors.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .glassCard(padding: 22, cornerRadius: 24)
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        DawnButton(label: "Amen 🙏") {
                            didPray = true
                            withAnimation { page = 6 }
                        }
                        Button {
                            withAnimation { page = 7 }
                        } label: {
                            Text("Skip")
                                .font(.custom("Outfit", size: 14.5))
                                .foregroundStyle(AnchoredColors.inkMute)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)
                }
            }
            .onAppear {
                if prayerText.isEmpty && !prayerLoading {
                    Task { await generatePrayer() }
                }
            }
        }
    }

    @MainActor
    private func generatePrayer() async {
        guard case .done(let rec) = demoPhase, let verse = rec.verses.first else {
            prayerText = "Lord, thank You for meeting me right where I am. Help me hold onto Your Word today and find peace in Your presence. Amen."
            return
        }
        prayerLoading = true
        prayerText = verse.prayer
        prayerLoading = false
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 07 Reward (SparkleBurst)
    // ────────────────────────────────────────────────────────────────

    private var rewardPage: some View {
        ZStack {
            BrandHeader(step: 4, total: totalSteps)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // Sparkle dots
            sparkleDots

            VStack(spacing: 10) {
                // Central sparkle icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AnchoredColors.coralSoft, .clear],
                                center: .center,
                                startRadius: 0, endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                    Circle()
                        .fill(AnchoredColors.gradientPrimary)
                        .frame(width: 80, height: 80)
                        .shadow(color: AnchoredColors.coral.opacity(0.5), radius: 20, x: 0, y: 16)
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 20)

                VStack(spacing: 0) {
                    Text("He hears")
                        .font(.custom("Newsreader", size: 32).weight(.regular))
                        .tracking(-0.64)
                    Text("every word.")
                        .font(.custom("Newsreader", size: 32).weight(.regular).italic())
                        .tracking(-0.64)
                        .foregroundStyle(AnchoredColors.coral)
                }
                .foregroundStyle(AnchoredColors.ink)
                .multilineTextAlignment(.center)

                Text("Prayer is how we draw close.")
                    .font(.custom("Outfit", size: 14))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .padding(.bottom, 14)

                // XP pill
                HStack(spacing: 8) {
                    Text("+100")
                        .font(.custom("Newsreader", size: 20).weight(.semibold))
                        .foregroundStyle(AnchoredColors.coral)
                    Text("XP")
                        .font(.custom("Outfit", size: 11).weight(.semibold))
                        .tracking(1.65)
                        .foregroundStyle(AnchoredColors.inkSoft)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.white, in: Capsule())
                .shadow(color: AnchoredColors.coral.opacity(0.3), radius: 11, x: 0, y: 8)
                .overlay(Capsule().stroke(AnchoredColors.coralSoft, lineWidth: 1))
                .scaleEffect(xpScale)
            }
            .padding(.horizontal, 32)

            DawnBottomButton(label: "Continue") {
                withAnimation { page = 7 }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.4)) {
                xpScale = 1.0
            }
            Task {
                let manager = StreakManager(modelContext: modelContext, userId: "onboarding")
                manager.awardXP(100)
            }
        }
    }

    private var sparkleDots: some View {
        GeometryReader { _ in
            ForEach(0..<35, id: \.self) { i in
                let x = CGFloat(30 + (i * 23) % 310)
                let y = CGFloat(130 + (i * 47) % 480)
                let size = CGFloat(2 + (i % 5))
                let colors: [Color] = [AnchoredColors.coral, AnchoredColors.gold, AnchoredColors.lilac, AnchoredColors.blue]
                let opacity = 0.3 + Double(i % 5) / 10.0
                Circle()
                    .fill(colors[i % 4])
                    .frame(width: size, height: size)
                    .opacity(opacity)
                    .position(x: x, y: y)
            }
        }
        .allowsHitTesting(false)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 08 Subscribe
    // ────────────────────────────────────────────────────────────────

    private var subscribePage: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    BrandHeader(step: 5, total: totalSteps)
                        .padding(.bottom, 18)

                    // Premium pill
                    Text("ANCHORED PREMIUM")
                        .font(.custom("Outfit", size: 11).weight(.semibold))
                        .tracking(0.44)
                        .foregroundStyle(AnchoredColors.coral)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(AnchoredColors.glass, in: Capsule())
                        .overlay(Capsule().stroke(AnchoredColors.coralSoft, lineWidth: 1))
                        .padding(.bottom, 10)

                    // Headline
                    HStack(spacing: 0) {
                        Text("Go ")
                            .font(.custom("Newsreader", size: 28).weight(.regular))
                            .tracking(-0.56)
                        Text("deeper")
                            .font(.custom("Newsreader", size: 28).weight(.regular).italic())
                            .tracking(-0.56)
                            .foregroundStyle(AnchoredColors.coral)
                        Text(".")
                            .font(.custom("Newsreader", size: 28).weight(.regular))
                            .tracking(-0.56)
                    }
                    .foregroundStyle(AnchoredColors.ink)
                    .padding(.bottom, 18)

                    // Feature list
                    let features = ["All 35 topics & 176 lessons", "5 Bible translations", "Verse Recommender", "All future content"]
                    VStack(spacing: 0) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AnchoredColors.gradientPrimary)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                Text(feature)
                                    .font(.custom("Outfit", size: 14))
                                    .foregroundStyle(AnchoredColors.ink)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .glassCard(padding: 22, cornerRadius: 22)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    // Price tiles
                    HStack(spacing: 10) {
                        // Weekly
                        Button {
                            selectedPlan = .weekly
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("WEEKLY")
                                    .font(.custom("Outfit", size: 11).weight(.semibold))
                                    .tracking(1.54)
                                    .foregroundStyle(AnchoredColors.inkSoft)
                                    .padding(.bottom, 4)
                                Text(premiumManager.weeklyProduct?.displayPrice ?? "$0.99")
                                    .font(.custom("Newsreader", size: 30).weight(.medium))
                                    .foregroundStyle(AnchoredColors.ink)
                                Text("per week")
                                    .font(.custom("Outfit", size: 11))
                                    .foregroundStyle(AnchoredColors.inkSoft)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassCard(padding: 18, cornerRadius: 20)
                        }
                        .buttonStyle(.plain)

                        // Yearly
                        Button {
                            selectedPlan = .yearly
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("YEARLY")
                                        .font(.custom("Outfit", size: 11).weight(.semibold))
                                        .tracking(1.54)
                                        .foregroundStyle(.white.opacity(0.85))
                                        .padding(.bottom, 4)
                                    Text(premiumManager.yearlyProduct?.displayPrice ?? "$29.99")
                                        .font(.custom("Newsreader", size: 30).weight(.medium))
                                        .foregroundStyle(.white)
                                    Text("per year · save 42%")
                                        .font(.custom("Outfit", size: 11))
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(18)
                                .background(AnchoredColors.gradientPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .shadow(color: AnchoredColors.coral.opacity(0.35), radius: 14, x: 0, y: 12)

                                Text("BEST")
                                    .font(.custom("Outfit", size: 10).weight(.bold))
                                    .tracking(0.44)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(AnchoredColors.ink, in: Capsule())
                                    .offset(x: -12, y: -9)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    // Subscribe button
                    DawnButton(label: "Begin subscription") {
                        Task { await premiumManager.purchase(selectedPlan) }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    // Footer links
                    Text("Terms · Privacy · Restore")
                        .font(.custom("Outfit", size: 11.5))
                        .foregroundStyle(AnchoredColors.inkSoft)
                        .padding(.bottom, 8)

                    Button {
                        withAnimation { page = 8 }
                    } label: {
                        Text("Continue with Free")
                            .font(.custom("Outfit", size: 13))
                            .foregroundStyle(AnchoredColors.inkMute)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 40)
                }
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - 09 Sign In
    // ────────────────────────────────────────────────────────────────

    private var signInPage: some View {
        ZStack {
            VStack(spacing: 0) {
                BrandHeader(step: 6, total: totalSteps)
                Spacer()
            }

            VStack(spacing: 24) {
                // Avatar with glow
                ZStack {
                    Circle()
                        .fill(AnchoredColors.gradientPrimary)
                        .frame(width: 130, height: 130)
                        .opacity(0.3)
                        .blur(radius: 20)
                    Circle()
                        .fill(.white)
                        .frame(width: 102, height: 102)
                        .overlay(
                            Circle().stroke(AnchoredColors.line, lineWidth: 1)
                        )
                        .shadow(color: AnchoredColors.coral.opacity(0.3), radius: 15, x: 0, y: 12)
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(AnchoredColors.coral)
                }

                VStack(spacing: 10) {
                    VStack(spacing: 0) {
                        Text("Almost ")
                            .font(.custom("Newsreader", size: 32).weight(.regular))
                            .tracking(-0.64)
                        + Text("there.")
                            .font(.custom("Newsreader", size: 32).weight(.regular).italic())
                            .tracking(-0.64)
                            .foregroundColor(AnchoredColors.coral)
                    }
                    .foregroundStyle(AnchoredColors.ink)
                    .multilineTextAlignment(.center)

                    Text("Save your progress so it travels with you.")
                        .font(.custom("Outfit", size: 14))
                        .foregroundStyle(AnchoredColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                }
            }
            .padding(.horizontal, 32)

            // Bottom actions
            VStack(spacing: 14) {
                Spacer()

                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
                        let userId = credential.user
                        let displayName: String? = credential.fullName.flatMap { name in
                            let parts = [name.givenName, name.familyName]
                                .compactMap { $0 }
                                .filter { !$0.isEmpty }
                            let joined = parts.joined(separator: " ")
                            return joined.isEmpty ? nil : joined
                        }
                        saveOnboardingAnswers(userId: userId)
                        authManager.completeSignIn(userId: userId, displayName: displayName)
                    case .failure:
                        break
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 54, maxHeight: 54)
                .clipShape(Capsule())

                Button {
                    saveOnboardingAnswers(userId: "00000000-0000-0000-0000-000000000000")
                    authManager.completeSignIn(userId: "00000000-0000-0000-0000-000000000000", displayName: "Test User")
                } label: {
                    Text("Skip for now")
                        .font(.custom("Outfit", size: 13))
                        .foregroundStyle(AnchoredColors.inkMute)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Helpers
    // ────────────────────────────────────────────────────────────────

    private func ensureSettingsRow() -> UserSettings {
        if let existing = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
            return existing
        }
        let fresh = UserSettings()
        modelContext.insert(fresh)
        return fresh
    }

    private func saveOnboardingAnswers(userId: String) {
        let settings: UserSettings
        if let existing = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
            settings = existing
        } else {
            settings = UserSettings(userId: userId)
            modelContext.insert(settings)
        }
        if let data = try? JSONEncoder().encode(Array(selectedGoals)),
           let str = String(data: data, encoding: .utf8) {
            settings.goals = str
        }
        if !selectedExperience.isEmpty {
            settings.bibleExperience = selectedExperience
        }
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AuthManager())
        .environmentObject(PremiumManager())
        .modelContainer(try! ModelContainer(for: UserSettings.self))
}
