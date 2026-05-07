//
//  OnboardingView.swift
//  Anchored
//
//  First-run onboarding. Nine screens driven by a TabView with a Next
//  button (not swipeable):
//
//  0. Welcome       — what Anchored is
//  1. Goals         — why they downloaded (multi-select chips)
//  2. Experience    — how familiar with the Bible (single select)
//  3. Notifications — opt-in toggle with inline time picker
//  4. Recommender   — interactive verse finder demo
//  5. Prayer        — generated prayer with Amen / Skip
//  6. Praise        — confetti + 100 XP celebration (only if prayed)
//  7. Subscription  — weekly/yearly pricing with Apple disclosures
//  8. Sign in       — Sign in with Apple
//

import SwiftUI
import SwiftData
import AuthenticationServices
import UIKit

struct OnboardingView: View {

    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext

    @State private var page: Int = 0

    // Answers
    @State private var selectedGoals: Set<String> = []
    @State private var selectedExperience: String = ""

    // Notification state (page 3)
    @State private var notificationsAccepted: Bool = false
    @State private var reminderDate: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    // Verse recommender state (page 4)
    @State private var demoInput: String = ""
    @State private var demoPhase: RecommenderDemoPhase = .idle
    @FocusState private var isFeelingFieldFocused: Bool
    enum RecommenderDemoPhase { case idle, loading, done(VerseRecommendation) }

    // Prayer state (pages 5-6)
    @State private var prayerText: String = ""
    @State private var prayerLoading: Bool = false
    @State private var didPray: Bool = false
    @State private var showConfetti: Bool = false
    @State private var xpScale: CGFloat = 0.5

    // Subscription state (page 7)
    @State private var selectedPlan: PremiumManager.Plan = .yearly

    private let totalPages = 9

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.06, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                // Branding bar — amber/parchment for dark bg
                HStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(AnchoredColors.amber)
                    Text("Anchored")
                        .anchoredStyle(.h3)
                        .foregroundStyle(AnchoredColors.parchment)
                }
                .padding(.top, 40)
                .padding(.bottom, 8)

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Circle()
                            .fill(i == page ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.3))
                            .frame(width: i == page ? 8 : 6, height: i == page ? 8 : 6)
                            .animation(.easeInOut(duration: 0.2), value: page)
                    }
                }
                .padding(.bottom, 16)

                // Page content
                TabView(selection: $page) {
                    welcomePage.tag(0)
                    goalsPage.tag(1)
                    experiencePage.tag(2)
                    notificationPage.tag(3)
                    recommenderDemoPage.tag(4)
                    prayerPage.tag(5)
                    praisePage.tag(6)
                    subscriptionPage.tag(7)
                    signInPage.tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                // Next button — hidden for pages 5+ (they have their own nav)
                if page < 5 {
                    nextButton
                        .screenPadding()
                        .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Next button

    private var nextButton: some View {
        Button {
            // Page 3: save notification time if accepted
            if page == 3 && notificationsAccepted {
                let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                let hour = comps.hour ?? 8
                let minute = comps.minute ?? 0
                let row = ensureSettingsRow()
                row.dailyReminderTime = String(format: "%02d:%02d", hour, minute)
                row.notificationsEnabled = true
                try? modelContext.save()
                Task {
                    _ = await NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
                }
            }
            // Page 4: dismiss keyboard, start loading prayer
            if page == 4 {
                isFeelingFieldFocused = false
                Task { await generatePrayer() }
            }
            withAnimation { page += 1 }
        } label: {
            Text("Continue")
                .anchoredStyle(.bodyMd)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(nextEnabled ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!nextEnabled)
    }

    private var nextEnabled: Bool {
        switch page {
        case 1: return !selectedGoals.isEmpty
        case 2: return !selectedExperience.isEmpty
        default: return true
        }
    }

    // MARK: - Onboarding card helper

    private func onboardingCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16, content: content)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AnchoredColors.navy)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Page 0: Welcome

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)
            ZStack {
                Circle()
                    .fill(AnchoredColors.amber.opacity(0.14))
                    .frame(width: 140, height: 140)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(AnchoredColors.amber)
            }
            VStack(spacing: 12) {
                Text("Welcome to Anchored")
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.amber)
                    .multilineTextAlignment(.center)
                Text("Read, study, and reflect on the Bible at your own pace. Built for beginners and lifelong learners alike.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .screenPadding()
            Spacer(minLength: 20)
        }
    }

    // MARK: - Page 1: Goals

    private let goals: [(id: String, label: String, icon: String)] = [
        ("faith",      "Grow in faith",           "heart.fill"),
        ("reading",    "Read the Bible regularly", "book.fill"),
        ("knowledge",  "Deepen Bible knowledge",   "lightbulb.fill"),
        ("prayer",     "Strengthen prayer life",   "hands.sparkles.fill"),
        ("comfort",    "Find comfort",             "hand.raised.fill"),
        ("devotional", "Daily devotional",         "sun.max.fill"),
    ]

    private var goalsPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Why did you download Anchored?")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.amber)
                Text("Select all that apply.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(goals, id: \.id) { goal in
                    goalChip(goal)
                }
            }

            Spacer()
        }
        .screenPadding()
        .padding(.top, 8)
    }

    private func goalChip(_ goal: (id: String, label: String, icon: String)) -> some View {
        let selected = selectedGoals.contains(goal.id)
        return Button {
            if selected { selectedGoals.remove(goal.id) } else { selectedGoals.insert(goal.id) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: goal.icon)
                    .font(.system(size: 13))
                Text(goal.label)
                    .anchoredStyle(.caption)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .foregroundStyle(selected ? .white : AnchoredColors.parchment)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .background(selected ? AnchoredColors.amber : AnchoredColors.navy)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? Color.clear : AnchoredColors.parchment.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Page 2: Experience

    private let experiences: [(id: String, label: String, sub: String)] = [
        ("new",      "New to the Bible",  "Just getting started"),
        ("some",     "Some familiarity",  "I've read parts of it"),
        ("regular",  "Regular reader",    "I read the Bible often"),
        ("lifelong", "Lifelong student",  "It's central to my life"),
    ]

    private var experiencePage: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("How familiar are you with the Bible?")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.amber)
            }

            VStack(spacing: 10) {
                ForEach(experiences, id: \.id) { exp in
                    experienceRow(exp)
                }
            }

            Spacer()
        }
        .screenPadding()
        .padding(.top, 8)
    }

    private func experienceRow(_ exp: (id: String, label: String, sub: String)) -> some View {
        let selected = selectedExperience == exp.id
        return Button {
            selectedExperience = exp.id
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exp.label)
                        .anchoredStyle(.bodyMd)
                        .foregroundStyle(selected ? .white : AnchoredColors.parchment)
                    Text(exp.sub)
                        .anchoredStyle(.caption)
                        .foregroundStyle(selected ? .white.opacity(0.75) : AnchoredColors.parchment.opacity(0.5))
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(selected ? AnchoredColors.amber : AnchoredColors.navy)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? Color.clear : AnchoredColors.parchment.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Page 3: Notifications

    private var notificationPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                onboardingCard {
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AnchoredColors.amber.opacity(0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(AnchoredColors.amber)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Stay rooted in the Word")
                                .anchoredStyle(.h2)
                                .foregroundStyle(AnchoredColors.amber)
                            Text("A daily reminder helps you build a consistent Bible habit. You can change this any time in Settings.")
                                .anchoredStyle(.body)
                                .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                onboardingCard {
                    Toggle(isOn: $notificationsAccepted) {
                        Text("Enable daily reminder")
                            .anchoredStyle(.bodyMd)
                            .foregroundStyle(AnchoredColors.parchment)
                    }
                    .tint(AnchoredColors.amber)
                    .onChange(of: notificationsAccepted) { _, accepted in
                        if accepted {
                            Task {
                                _ = await NotificationService.shared.requestAuthorization()
                            }
                        }
                    }

                    if notificationsAccepted {
                        Divider()
                            .background(AnchoredColors.parchment.opacity(0.15))

                        Text("Reminder time")
                            .anchoredStyle(.label)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.6))

                        DatePicker(
                            "",
                            selection: $reminderDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer(minLength: 20)
            }
            .screenPadding()
            .padding(.top, 8)
        }
    }

    // MARK: - Page 4: Verse Recommender Demo

    private var recommenderDemoPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AnchoredColors.amber)
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Find verses for how you feel")
                            .anchoredStyle(.h2)
                            .foregroundStyle(AnchoredColors.amber)
                        Text("Tap the sparkles button in the Bible tab anytime you need scripture that speaks to your situation.")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Interactive input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Try it now — how are you feeling?")
                        .anchoredStyle(.label)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.6))

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $demoInput)
                            .focused($isFeelingFieldFocused)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(AnchoredColors.parchment)
                            .padding(8)
                            .frame(minHeight: 80, maxHeight: 120)
                            .background(AnchoredColors.navy)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AnchoredColors.parchment.opacity(0.2), lineWidth: 1)
                            )
                        if demoInput.isEmpty {
                            Text("e.g. \"I'm anxious about a big decision…\"")
                                .anchoredStyle(.body)
                                .foregroundStyle(AnchoredColors.parchment.opacity(0.4))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                        }
                    }

                    Button {
                        isFeelingFieldFocused = false
                        Task { await runDemoRecommender() }
                    } label: {
                        HStack(spacing: 8) {
                            if case .loading = demoPhase {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text({ if case .idle = demoPhase { return "Find verses" }; return "Find again" }())
                                .anchoredStyle(.bodyMd)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(demoInput.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
                                    ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(demoInput.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                }

                // Results preview (first verse only)
                if case .done(let rec) = demoPhase, let first = rec.verses.first {
                    onboardingCard {
                        Text(first.reference)
                            .anchoredStyle(.reference)
                            .foregroundStyle(AnchoredColors.amber)
                        Text(first.text)
                            .anchoredStyle(.scripture)
                            .foregroundStyle(AnchoredColors.parchment)
                        Text(first.explanation)
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                            .lineLimit(3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 20)
            }
            .screenPadding()
            .padding(.top, 8)
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

    // MARK: - Page 5: Prayer

    private var prayerPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 12)

                onboardingCard {
                    HStack(spacing: 12) {
                        Text("🙏")
                            .font(.system(size: 32))
                        Text("Let's Talk to God")
                            .anchoredStyle(.h2)
                            .foregroundStyle(AnchoredColors.amber)
                    }

                    if prayerLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(AnchoredColors.amber)
                            Text("Preparing a prayer for you...")
                                .anchoredStyle(.body)
                                .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
                        }
                        .padding(.vertical, 8)
                    } else if !prayerText.isEmpty {
                        Text(prayerText)
                            .anchoredStyle(.scripture)
                            .foregroundStyle(AnchoredColors.parchment)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Take a moment to pray this to the Lord.")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                    } else {
                        Text("A personal prayer will be prepared based on your verse.")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .screenPadding()

                VStack(spacing: 12) {
                    // Amen button
                    Button {
                        didPray = true
                        withAnimation { page = 6 }
                    } label: {
                        Text("Amen 🙏")
                            .anchoredStyle(.bodyMd)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(AnchoredColors.amber)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    // Skip button
                    Button {
                        withAnimation { page = 7 }
                    } label: {
                        Text("Skip")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                .screenPadding()

                Spacer(minLength: 20)
            }
        }
        .onAppear {
            if prayerText.isEmpty && !prayerLoading {
                Task { await generatePrayer() }
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

    // MARK: - Page 6: Praise

    private var praisePage: some View {
        ZStack {
            ConfettiView()
                .ignoresSafeArea()
                .opacity(showConfetti ? 1 : 0)

            VStack(spacing: 28) {
                Spacer(minLength: 20)

                ZStack {
                    Circle()
                        .fill(AnchoredColors.amber.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(AnchoredColors.amber)
                }

                VStack(spacing: 12) {
                    Text("God heard every word.")
                        .anchoredStyle(.h1)
                        .foregroundStyle(AnchoredColors.amber)
                        .multilineTextAlignment(.center)

                    Text("Prayer is how we grow closer to Him.")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .screenPadding()

                // +100 XP badge
                Text("+100 XP")
                    .anchoredStyle(.xpDigit)
                    .foregroundStyle(AnchoredColors.amber)
                    .scaleEffect(xpScale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: xpScale)

                Spacer(minLength: 20)

                Button {
                    withAnimation { page = 7 }
                } label: {
                    Text("Continue")
                        .anchoredStyle(.bodyMd)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(AnchoredColors.amber)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .screenPadding()
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            showConfetti = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                xpScale = 1.0
            }
            Task {
                let manager = StreakManager(modelContext: modelContext, userId: "onboarding")
                manager.awardXP(100)
            }
        }
    }

    // MARK: - Page 7: Subscription

    private var subscriptionPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AnchoredColors.amber.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AnchoredColors.amber)
                    }
                    Text("Unlock Anchored Premium")
                        .anchoredStyle(.h2)
                        .foregroundStyle(AnchoredColors.amber)
                }

                // Feature list card
                onboardingCard {
                    featureRow(icon: "book.fill",          text: "All 5 Bible translations")
                    featureRow(icon: "highlighter",         text: "Verse highlighting & notes")
                    featureRow(icon: "sparkles",            text: "Unlimited AI verse recommendations")
                    featureRow(icon: "bell.fill",           text: "Daily verse push notifications")
                }

                // Plan cards side by side
                HStack(spacing: 12) {
                    planCard(plan: .weekly)
                    planCard(plan: .yearly)
                }

                // Subscribe button
                Button {
                    Task { await premiumManager.purchase(selectedPlan) }
                } label: {
                    Group {
                        if premiumManager.purchaseState == .purchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text("Subscribe")
                                .anchoredStyle(.bodyMd)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AnchoredColors.amber)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(premiumManager.purchaseState == .purchasing)

                // Apple disclosures
                VStack(spacing: 8) {
                    Text("Subscriptions auto-renew until canceled. Cancel anytime in your Apple ID settings. Prices may vary by region.")
                        .anchoredStyle(.caption)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.4))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .anchoredStyle(.caption)
                            .foregroundStyle(AnchoredColors.amber.opacity(0.8))

                        Link("Privacy Policy", destination: URL(string: "https://patricio1564.github.io/Anchored/privacy-policy")!)
                            .anchoredStyle(.caption)
                            .foregroundStyle(AnchoredColors.amber.opacity(0.8))
                    }

                    Button {
                        Task { await premiumManager.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .anchoredStyle(.caption)
                            .foregroundStyle(AnchoredColors.amber)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)

                // Continue with Free
                Button {
                    withAnimation { page = 8 }
                } label: {
                    Text("Continue with Free")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.4))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 20)
            }
            .screenPadding()
            .padding(.top, 8)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AnchoredColors.amber)
            Text(text)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.parchment)
            Spacer()
        }
    }

    private func planCard(plan: PremiumManager.Plan) -> some View {
        let isWeekly = plan == .weekly
        let isSelected = selectedPlan == plan
        let price = isWeekly
            ? (premiumManager.weeklyProduct?.displayPrice ?? "$0.99")
            : (premiumManager.yearlyProduct?.displayPrice ?? "$29.99")
        let period = isWeekly ? "/ week" : "/ year"
        let title = isWeekly ? "Weekly" : "Yearly"

        return Button {
            selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .anchoredStyle(.label)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
                    Spacer()
                    if !isWeekly {
                        Text("Best Value")
                            .anchoredStyle(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AnchoredColors.amber)
                            .clipShape(Capsule())
                    }
                }
                Text(price)
                    .anchoredStyle(.xpDigit)
                    .foregroundStyle(AnchoredColors.parchment)
                Text(period)
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                if !isWeekly {
                    Text("Save 42%")
                        .anchoredStyle(.caption)
                        .foregroundStyle(AnchoredColors.amber)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AnchoredColors.navy)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Page 8: Sign In

    private var signInPage: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            ZStack {
                Circle()
                    .fill(AnchoredColors.amber.opacity(0.14))
                    .frame(width: 140, height: 140)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(AnchoredColors.amber)
            }

            VStack(spacing: 10) {
                Text("Almost there")
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.amber)
                    .multilineTextAlignment(.center)
                Text("Create your account to save your progress across devices.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .screenPadding()

            Spacer(minLength: 20)

            VStack(spacing: 12) {
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
                .signInWithAppleButtonStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                #if DEBUG
                Button("Skip sign in (debug)") {
                    saveOnboardingAnswers(userId: "00000000-0000-0000-0000-000000000000")
                    authManager.completeSignIn(userId: "00000000-0000-0000-0000-000000000000", displayName: "Test User")
                }
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                #endif

                Text("By continuing, you agree to our Terms and Privacy Policy.")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .screenPadding()
            .padding(.bottom, 24)
        }
    }

    // MARK: - Helpers

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

// MARK: - ConfettiView

private struct ConfettiView: View {
    @State private var particles: [(x: CGFloat, y: CGFloat, color: Color, size: CGFloat, speed: CGFloat)] = []
    @State private var timer: Timer?

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, _ in
                for p in particles {
                    let rect = CGRect(x: p.x, y: p.y, width: p.size, height: p.size)
                    context.fill(Path(ellipseIn: rect), with: .color(p.color))
                }
            }
        }
        .onAppear { startConfetti() }
        .onDisappear { timer?.invalidate() }
    }

    private func startConfetti() {
        let colors: [Color] = [
            AnchoredColors.amber,
            .yellow,
            .orange,
            .white,
            AnchoredColors.amber.opacity(0.6)
        ]
        let screenWidth = UIScreen.main.bounds.width
        particles = (0..<60).map { _ in
            (
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -200...(-20)),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...8),
                speed: CGFloat.random(in: 2...5)
            )
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].speed
                particles[i].x += CGFloat.random(in: -1...1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AuthManager())
        .environmentObject(PremiumManager())
        .modelContainer(try! ModelContainer(for: UserSettings.self))
}
