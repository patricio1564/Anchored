//
//  OnboardingView.swift
//  Anchored
//
//  First-run onboarding. Six screens driven by a TabView with a Next
//  button (not swipeable — the subscription slide needs deliberate intent):
//
//  0. Welcome       — what Anchored is
//  1. Goals         — why they downloaded (multi-select chips)
//  2. Experience    — how familiar with the Bible (single select)
//  3. Subscription  — monthly vs yearly pricing comparison
//  4. Recommender   — interactive demo of the sparkles verse finder
//  5. Sign in       — Sign in with Apple (existing flow)
//
//  Goal/experience answers are saved to UserSettings after sign-in.
//  The subscription slide purchases via PremiumManager or lets the user
//  skip to the free tier.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct OnboardingView: View {

    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext

    @State private var page: Int = 0

    // Answers collected during onboarding
    @State private var selectedGoals: Set<String> = []
    @State private var selectedExperience: String = ""

    // Recommender demo state (slide 4)
    @State private var demoInput: String = ""
    @State private var demoPhase: RecommenderDemoPhase = .idle
    enum RecommenderDemoPhase { case idle, loading, done(VerseRecommendation) }

    private let totalPages = 6

    var body: some View {
        ZStack {
            AnchoredColors.parchment.ignoresSafeArea()

            VStack(spacing: 0) {
                // Branding
                HStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(AnchoredColors.amber)
                    Text("Anchored")
                        .anchoredStyle(.h3)
                        .foregroundStyle(AnchoredColors.navy)
                }
                .padding(.top, 40)
                .padding(.bottom, 8)

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Circle()
                            .fill(i == page ? AnchoredColors.amber : AnchoredColors.border)
                            .frame(width: i == page ? 8 : 6, height: i == page ? 8 : 6)
                            .animation(.easeInOut(duration: 0.2), value: page)
                    }
                }
                .padding(.bottom, 16)

                // Page content — non-swipeable TabView
                TabView(selection: $page) {
                    welcomePage.tag(0)
                    goalsPage.tag(1)
                    experiencePage.tag(2)
                    subscriptionPage.tag(3)
                    recommenderDemoPage.tag(4)
                    signInPage.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                // Next / Continue button (hidden on sign-in page)
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
            withAnimation { page += 1 }
        } label: {
            Text(page == 2 ? "See plans" : page == 3 ? "Try a feature" : "Continue")
                .anchoredStyle(.bodyMd)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(nextEnabled ? AnchoredColors.navy : AnchoredColors.border)
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
                    .foregroundStyle(AnchoredColors.navy)
                    .multilineTextAlignment(.center)
                Text("Read, study, and reflect on the Bible at your own pace. Built for beginners and lifelong learners alike.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
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
                    .foregroundStyle(AnchoredColors.navy)
                Text("Select all that apply.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
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
            .foregroundStyle(selected ? .white : AnchoredColors.navy)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .background(selected ? AnchoredColors.navy : AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? Color.clear : AnchoredColors.border, lineWidth: 1)
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
                    .foregroundStyle(AnchoredColors.navy)
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
                        .foregroundStyle(selected ? .white : AnchoredColors.navy)
                    Text(exp.sub)
                        .anchoredStyle(.caption)
                        .foregroundStyle(selected ? .white.opacity(0.75) : AnchoredColors.muted)
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
            .background(selected ? AnchoredColors.navy : AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? Color.clear : AnchoredColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Page 3: Subscription

    private var subscriptionPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Unlock everything in Anchored")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.navy)
                Text("All translations, verse highlights, and more.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
            }
            .screenPadding()

            HStack(spacing: 12) {
                planCard(
                    title: "Monthly",
                    price: premiumManager.monthlyProduct?.displayPrice ?? "—",
                    period: "/ month",
                    badge: nil,
                    isHighlighted: false
                ) {
                    Task { await premiumManager.purchase(.monthly) }
                }

                planCard(
                    title: "Yearly",
                    price: premiumManager.yearlyProduct?.displayPrice ?? "—",
                    period: "/ year",
                    badge: annualizedSavingsLabel,
                    isHighlighted: true
                ) {
                    Task { await premiumManager.purchase(.yearly) }
                }
            }
            .screenPadding()

            Button {
                withAnimation { page += 1 }
            } label: {
                Text("Continue with free")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .screenPadding()

            Spacer()
        }
        .padding(.top, 8)
    }

    private func planCard(
        title: String,
        price: String,
        period: String,
        badge: String?,
        isHighlighted: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .anchoredStyle(.label)
                        .foregroundStyle(isHighlighted ? .white : AnchoredColors.muted)
                    Spacer()
                    if let badge {
                        Text(badge)
                            .anchoredStyle(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
                Text(price)
                    .anchoredStyle(.xpDigit)
                    .foregroundStyle(isHighlighted ? .white : AnchoredColors.navy)
                Text(period)
                    .anchoredStyle(.caption)
                    .foregroundStyle(isHighlighted ? .white.opacity(0.8) : AnchoredColors.muted)
                if isHighlighted, let monthly = annualizedMonthlyPrice {
                    Text("= \(monthly) / mo")
                        .anchoredStyle(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHighlighted ? AnchoredColors.navy : AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isHighlighted ? Color.clear : AnchoredColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var annualizedMonthlyPrice: String? {
        guard let monthly = premiumManager.monthlyProduct,
              let yearly  = premiumManager.yearlyProduct else { return nil }
        let annualized = yearly.price / 12
        return monthly.priceFormatStyle.format(annualized)
    }

    private var annualizedSavingsLabel: String? {
        guard let monthly = premiumManager.monthlyProduct,
              let yearly  = premiumManager.yearlyProduct,
              monthly.price > 0 else { return nil }
        let annualized = yearly.price / 12
        let savings = ((monthly.price - annualized) / monthly.price * 100)
        let rounded = NSDecimalNumber(decimal: savings).intValue
        return "Save \(rounded)%"
    }

    // MARK: - Page 4: Verse Recommender Demo

    private var recommenderDemoPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header explaining the sparkles button
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
                        .foregroundStyle(AnchoredColors.navy)
                    Text("Tap the sparkles button in the Bible tab anytime you need scripture that speaks to your situation.")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .screenPadding()

            // Interactive input
            VStack(alignment: .leading, spacing: 10) {
                Text("Try it now — how are you feeling?")
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.muted)
                    .screenPadding()

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $demoInput)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(minHeight: 80, maxHeight: 120)
                        .background(AnchoredColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AnchoredColors.border, lineWidth: 1)
                        )
                    if demoInput.isEmpty {
                        Text("e.g. \"I'm anxious about a big decision…\"")
                            .anchoredStyle(.body)
                            .foregroundStyle(AnchoredColors.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
                .screenPadding()

                Button {
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
                                ? AnchoredColors.navy : AnchoredColors.border)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(demoInput.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                .screenPadding()
            }

            // Results preview (first verse only)
            if case .done(let rec) = demoPhase, let first = rec.verses.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text(first.reference)
                        .anchoredStyle(.reference)
                        .foregroundStyle(AnchoredColors.amber)
                    Text(first.text)
                        .anchoredStyle(.scripture)
                        .foregroundStyle(AnchoredColors.navy)
                    Text(first.explanation)
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.navy.opacity(0.8))
                        .lineLimit(3)
                }
                .cardSurface(padding: 16)
                .screenPadding()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    @MainActor
    private func runDemoRecommender() async {
        let query = demoInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 3 else { return }
        withAnimation { demoPhase = .loading }
        let result = await VerseRecommenderService.shared.recommend(for: query)
        withAnimation { demoPhase = .done(result) }
    }

    // MARK: - Page 5: Sign in

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
                    .foregroundStyle(AnchoredColors.navy)
                    .multilineTextAlignment(.center)
                Text("Create your account to save your progress across devices.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
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
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                #if DEBUG
                Button("Skip sign in (debug)") {
                    saveOnboardingAnswers(userId: "00000000-0000-0000-0000-000000000000")
                    authManager.completeSignIn(userId: "00000000-0000-0000-0000-000000000000", displayName: "Test User")
                }
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.muted)
                #endif

                Text("By continuing, you agree to our Terms and Privacy Policy.")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
                    .multilineTextAlignment(.center)
            }
            .screenPadding()
            .padding(.bottom, 24)
        }
    }

    // MARK: - Persist answers

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
