//
//  ProfileView.swift
//  Anchored
//
//  The "Profile" tab. Two major sections:
//
//  1. Progress dashboard — streak, XP progress toward next level,
//     lifetime lesson count, and the 8 achievement badges with
//     unlocked / locked visual treatment.
//
//  2. Settings — preferred translation (respects premium gating),
//     font size, daily-reminder toggle (with real permission flow),
//     and sign-out.
//
//  Also hosts a hidden debug toggle for `PremiumManager.debugUnlock`
//  to make testing the paywall easy during development. The debug
//  block is compiled out of release builds.
//
//  ───── Notification permission flow ─────
//  The toggle prompts for permission the first time it's flipped on.
//  If permission was previously denied we surface a Settings deep-link
//  button instead of silently failing. This matches the Layer 2
//  README's "contextual, never at launch" philosophy.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ProfileView: View {

    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext

    // MARK: - Live data

    /// Lazily-constructed streak manager. We hold it across renders so
    /// mutations (reset, award XP from debug) don't rebuild state.
    @State private var streak: StreakManager?

    /// Live query of all progress rows. Drives the achievement checks
    /// and the lifetime lesson count.
    @Query private var progressRows: [LessonProgress]

    /// Settings row — there should only ever be one. If for some reason
    /// there's no row yet, we lazy-create on first edit.
    @Query private var settingsRows: [UserSettings]

    // MARK: - UI state

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isReminderOn: Bool = false
    @State private var reminderHour: Int = 8
    @State private var reminderMinute: Int = 0

    @State private var showSignOutConfirm = false
    @State private var showResetConfirm = false
    @State private var selectedAchievement: Achievement?
    @State private var isRestoring = false
    @State private var showOfferCodeSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statsGrid
                levelCard
                subscriptionSection
                achievementsSection
                settingsSection
                signOutButton
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .screenPadding()
        }
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task { await bootstrap() }
        .sheet(isPresented: $premiumManager.isShowingPaywall) {
            PaywallSheet()
        }
        .sheet(isPresented: $showOfferCodeSheet) {
            OfferCodeSheet(premiumManager: premiumManager, isPresented: $showOfferCodeSheet)
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement, snapshot: buildSnapshot())
        }
        .alert("Sign out?", isPresented: $showSignOutConfirm) {
            Button("Sign out", role: .destructive) { authManager.signOut() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress stays on this device.")
        }
        .alert("Reset progress?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) { streak?.reset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your streak and XP. Completed lessons remain.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            // Circular avatar with initials
            ZStack {
                Circle()
                    .fill(AnchoredColors.amber.opacity(0.18))
                    .frame(width: 56, height: 56)
                Text(initials)
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.amber)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.navy)
                Text(premiumManager.isPremium ? "Premium member" : "Free account")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
            Spacer()
        }
    }

    // MARK: - Stats

    private var statsGrid: some View {
        HStack(spacing: 12) {
            stat(icon: "flame.fill", tint: AnchoredColors.streak,
                 value: "\(streak?.currentStreak ?? 0)", label: "Streak")
            stat(icon: "trophy.fill", tint: AnchoredColors.amber,
                 value: "\(streak?.longestStreak ?? 0)", label: "Best")
            stat(icon: "book.fill", tint: AnchoredColors.navy,
                 value: "\(completedLessonsCount)", label: "Lessons")
        }
    }

    private func stat(icon: String, tint: Color, value: String, label: String) -> some View {
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

    // MARK: - Level / XP

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Level \(streak?.level ?? 1)")
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
                Text(streak?.levelTitle ?? "Seeker")
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.amber)
            }
            if let streak {
                ProgressView(value: Double(streak.xpInCurrentLevel),
                             total: Double(streak.xpForCurrentLevel))
                    .progressViewStyle(.linear)
                    .tint(AnchoredColors.amber)
                Text("\(streak.xpInCurrentLevel) / \(streak.xpForCurrentLevel) XP to next level")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 20)
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        Group {
            if premiumManager.isPremium {
                premiumActiveCard
            } else {
                upgradeCard
            }
        }
    }

    private var upgradeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AnchoredColors.amber.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: "star.fill")
                        .foregroundStyle(AnchoredColors.amber)
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unlock Premium")
                        .anchoredStyle(.bodyMd)
                        .foregroundStyle(AnchoredColors.navy)
                    Text("All translations, verse highlights, and more.")
                        .anchoredStyle(.caption)
                        .foregroundStyle(AnchoredColors.muted)
                }
                Spacer()
                Button {
                    premiumManager.presentPaywall()
                } label: {
                    Text("Upgrade")
                        .anchoredStyle(.label)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AnchoredColors.amber)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Button {
                showOfferCodeSheet = true
            } label: {
                Text("Have an offer code?")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.amber)
            }
            .buttonStyle(.plain)
        }
        .cardSurface(padding: 16)
    }

    private var premiumActiveCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AnchoredColors.amber)
                Text("Premium Active")
                    .anchoredStyle(.bodyMd)
                    .foregroundStyle(AnchoredColors.navy)
                Spacer()
            }
            HStack(spacing: 10) {
                Button {
                    guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
                    #if canImport(UIKit)
                    UIApplication.shared.open(url)
                    #endif
                } label: {
                    Text("Manage Subscription")
                        .anchoredStyle(.label)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(AnchoredColors.card)
                        .foregroundStyle(AnchoredColors.navy)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AnchoredColors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button {
                    Task {
                        isRestoring = true
                        await premiumManager.restorePurchases()
                        isRestoring = false
                    }
                } label: {
                    Group {
                        if isRestoring {
                            ProgressView().tint(AnchoredColors.navy)
                        } else {
                            Text("Restore")
                                .anchoredStyle(.label)
                                .foregroundStyle(AnchoredColors.navy)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(AnchoredColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AnchoredColors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(isRestoring)
            }
        }
        .cardSurface(padding: 16)
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .anchoredStyle(.h2)
                .foregroundStyle(AnchoredColors.navy)

            // 4-column grid: fits 8 badges cleanly on iPhone portrait.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                      spacing: 12) {
                ForEach(Achievements.all) { achievement in
                    achievementCell(achievement)
                }
            }
        }
    }

    private func achievementCell(_ achievement: Achievement) -> some View {
        let snapshot = buildSnapshot()
        let unlocked = achievement.isUnlocked(snapshot)
        return Button { selectedAchievement = achievement } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(unlocked ? AnyShapeStyle(achievement.gradient.linearGradient)
                                       : AnyShapeStyle(AnchoredColors.border))
                        .frame(width: 48, height: 48)
                    Image(systemName: achievement.sfSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(unlocked ? .white : AnchoredColors.muted)
                }
                Text(achievement.title)
                    .anchoredStyle(.caption)
                    .foregroundStyle(unlocked ? AnchoredColors.navy : AnchoredColors.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(achievement.title). \(unlocked ? "Unlocked." : "Locked.") \(achievement.description)")
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .anchoredStyle(.h2)
                .foregroundStyle(AnchoredColors.navy)

            VStack(spacing: 0) {
                translationRow
                Divider().background(AnchoredColors.border)
                fontSizeRow
                Divider().background(AnchoredColors.border)
                reminderRow
                if notificationStatus == .denied {
                    Divider().background(AnchoredColors.border)
                    openSettingsRow
                }
                #if DEBUG
                Divider().background(AnchoredColors.border)
                debugPremiumRow
                Divider().background(AnchoredColors.border)
                resetRow
                #endif
            }
            .cardSurface(padding: 0)
        }
    }

    private var translationRow: some View {
        settingRow {
            Label("Translation", systemImage: "globe")
                .foregroundStyle(AnchoredColors.navy)
        } trailing: {
            // Picker over all translations — tapping a locked one still
            // shows the option, but selection is blocked and the paywall
            // presents. Enforced in the onChange handler below.
            Picker("", selection: Binding(
                get: { currentTranslation },
                set: { newValue in
                    if newValue.isFree || premiumManager.isPremium {
                        updateTranslation(newValue)
                    } else {
                        premiumManager.presentPaywall()
                    }
                }
            )) {
                ForEach(BibleTranslation.allCases) { option in
                    HStack {
                        Text(option.displayName)
                        if !option.isFree && !premiumManager.isPremium {
                            Image(systemName: "lock.fill")
                        }
                    }
                    .tag(option)
                }
            }
            .labelsHidden()
            .tint(AnchoredColors.amber)
        }
    }

    private var fontSizeRow: some View {
        settingRow {
            Label("Font size", systemImage: "textformat.size")
                .foregroundStyle(AnchoredColors.navy)
        } trailing: {
            Picker("", selection: Binding(
                get: { currentFontSize },
                set: { updateFontSize($0) }
            )) {
                ForEach(FontSizeScale.allCases, id: \.self) { size in
                    Text(size.displayName).tag(size)
                }
            }
            .labelsHidden()
            .tint(AnchoredColors.amber)
        }
    }

    private var reminderRow: some View {
        settingRow {
            Label("Daily reminder", systemImage: "bell.fill")
                .foregroundStyle(AnchoredColors.navy)
        } trailing: {
            Toggle("", isOn: Binding(
                get: { isReminderOn },
                set: { newValue in Task { await setReminder(enabled: newValue) } }
            ))
            .labelsHidden()
            .tint(AnchoredColors.amber)
        }
    }

    private var openSettingsRow: some View {
        Button {
            openSystemSettings()
        } label: {
            settingRow {
                Label("Open iOS Settings", systemImage: "arrow.up.right.square")
                    .foregroundStyle(AnchoredColors.amber)
            } trailing: {
                Text("Notifications denied")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.muted)
            }
        }
        .buttonStyle(.plain)
    }

    #if DEBUG
    private var debugPremiumRow: some View {
        settingRow {
            Label("Debug: Premium", systemImage: "hammer.fill")
                .foregroundStyle(AnchoredColors.muted)
        } trailing: {
            Toggle("", isOn: Binding(
                get: { premiumManager.isPremium },
                set: { $0 ? premiumManager.debugUnlock() : premiumManager.debugLock() }
            ))
            .labelsHidden()
            .tint(AnchoredColors.amber)
        }
    }

    private var resetRow: some View {
        Button {
            showResetConfirm = true
        } label: {
            settingRow {
                Label("Reset progress", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(AnchoredColors.error)
            } trailing: {
                EmptyView()
            }
        }
        .buttonStyle(.plain)
    }
    #endif

    private func settingRow<L: View, T: View>(
        @ViewBuilder label: () -> L,
        @ViewBuilder trailing: () -> T
    ) -> some View {
        HStack {
            label()
                .anchoredStyle(.bodyMd)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Sign out

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            Text("Sign out")
                .anchoredStyle(.bodyMd)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(AnchoredColors.error)
                .background(AnchoredColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AnchoredColors.border, lineWidth: 1)
                )
        }
    }

    // MARK: - Bootstrap

    /// Build the StreakManager, sync the reminder toggle to real state,
    /// and read current notification status.
    private func bootstrap() async {
        if streak == nil {
            let userId = authManager.currentUserId ?? "local-user"
            streak = StreakManager(modelContext: modelContext, userId: userId)
        }

        // Keep UI in sync with the actual system + settings state.
        let status = await NotificationService.shared.currentAuthorizationStatus()
        let scheduled = await NotificationService.shared.isDailyReminderScheduled()
        notificationStatus = status
        // Toggle is "on" only if we have permission AND a request is pending.
        isReminderOn = (status == .authorized || status == .provisional) && scheduled

        // Parse the stored reminder time if any.
        if let hm = currentReminderHHMM, let parsed = parseHHMM(hm) {
            reminderHour = parsed.hour
            reminderMinute = parsed.minute
        }
    }

    // MARK: - Settings mutations

    /// Ensure a UserSettings row exists before mutating it. Avoids the
    /// "tapped toggle on first launch, nothing happens" class of bug.
    /// Named `ensureSettingsRow` to avoid collision with the @Query
    /// property `settingsRows`.
    private func ensureSettingsRow() -> UserSettings {
        if let existing = settingsRows.first {
            return existing
        }
        let fresh = UserSettings(userId: authManager.currentUserId)
        modelContext.insert(fresh)
        try? modelContext.save()
        return fresh
    }

    private func updateTranslation(_ t: BibleTranslation) {
        let row = ensureSettingsRow()
        row.preferredTranslation = t.rawValue
        try? modelContext.save()
    }

    private func updateFontSize(_ size: FontSizeScale) {
        let row = ensureSettingsRow()
        row.fontSize = size
        try? modelContext.save()
    }

    /// Flip the daily reminder on/off. Handles the permission prompt on
    /// first-enable and schedules via NotificationService.
    private func setReminder(enabled: Bool) async {
        if enabled {
            // Ask for permission if we don't have it yet.
            var status = notificationStatus
            if status == .notDetermined {
                _ = await NotificationService.shared.requestAuthorization()
                status = await NotificationService.shared.currentAuthorizationStatus()
                notificationStatus = status
            }

            guard status == .authorized || status == .provisional else {
                // Denied or restricted — reflect real state, don't force on.
                isReminderOn = false
                return
            }

            let ok = await NotificationService.shared.scheduleDailyReminder(
                hour: reminderHour,
                minute: reminderMinute
            )
            isReminderOn = ok

            if ok {
                let row = ensureSettingsRow()
                row.notificationsEnabled = true
                row.dailyReminderTime = String(format: "%02d:%02d", reminderHour, reminderMinute)
                try? modelContext.save()
            }
        } else {
            NotificationService.shared.cancelDailyReminder()
            isReminderOn = false
            let row = ensureSettingsRow()
            row.notificationsEnabled = false
            try? modelContext.save()
        }
    }

    private func openSystemSettings() {
        guard let url = NotificationService.shared.settingsURL else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }

    // MARK: - Derived values

    private var displayName: String {
        if case let .signedIn(_, name) = authManager.state, let name, !name.isEmpty {
            return name
        }
        return settingsRows.first?.displayName ?? "Friend"
    }

    private var initials: String {
        let name = displayName
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? "A" : letters.uppercased()
    }

    private var completedLessonsCount: Int {
        progressRows.filter(\.completed).count
    }

    private var currentTranslation: BibleTranslation {
        if let raw = settingsRows.first?.preferredTranslation,
           let value = BibleTranslation(rawValue: raw) {
            return value
        }
        return .web
    }

    private var currentFontSize: FontSizeScale {
        settingsRows.first?.fontSize ?? .medium
    }

    private var currentReminderHHMM: String? {
        settingsRows.first?.dailyReminderTime
    }

    private func parseHHMM(_ s: String) -> (hour: Int, minute: Int)? {
        let parts = s.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    /// Build the achievement snapshot from live SwiftData + StreakManager.
    private func buildSnapshot() -> AchievementSnapshot {
        let lessonResults = progressRows
            .filter(\.completed)
            .map { AchievementSnapshot.LessonResult(
                lessonID: $0.lessonId,
                topicID: $0.topicId,
                score: $0.score
            ) }
        return AchievementSnapshot(
            completedLessons: lessonResults,
            longestStreak: streak?.longestStreak ?? 0,
            totalXP: streak?.totalXP ?? 0
        )
    }
}

// MARK: - Offer Code Sheet

private struct OfferCodeSheet: View {
    let premiumManager: PremiumManager
    @Binding var isPresented: Bool
    @State private var code = ""
    @State private var result: PremiumManager.RedeemResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AnchoredColors.amber.opacity(0.14))
                        .frame(width: 64, height: 64)
                    Image(systemName: "ticket.fill")
                        .foregroundStyle(AnchoredColors.amber)
                        .font(.system(size: 26))
                }
                .padding(.top, 8)

                Text("Redeem Offer Code")
                    .anchoredStyle(.h3)
                    .foregroundStyle(AnchoredColors.navy)

                Text("Enter your code to unlock Anchored Premium.")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
                    .multilineTextAlignment(.center)

                TextField("e.g. ANCHORED-BETA", text: $code)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(AnchoredColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AnchoredColors.border, lineWidth: 1)
                    )

                if let result {
                    switch result {
                    case .success:
                        Label("Premium unlocked!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .anchoredStyle(.bodyMd)
                    case .invalid:
                        Label("Invalid code. Please try again.", systemImage: "xmark.circle.fill")
                            .foregroundStyle(AnchoredColors.error)
                            .anchoredStyle(.bodyMd)
                    case .alreadyRedeemed:
                        Label("A code has already been redeemed on this device.", systemImage: "info.circle.fill")
                            .foregroundStyle(AnchoredColors.muted)
                            .anchoredStyle(.bodyMd)
                    }
                }

                Button {
                    let r = premiumManager.redeemOfferCode(code)
                    result = r
                    if r == .success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            isPresented = false
                        }
                    }
                } label: {
                    Text("Redeem")
                        .anchoredStyle(.bodyMd)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(code.isEmpty ? AnchoredColors.amber.opacity(0.4) : AnchoredColors.amber)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(code.isEmpty)
                .buttonStyle(.plain)

                Spacer()
            }
            .screenPadding()
            .background(AnchoredColors.parchment.ignoresSafeArea())
            .navigationTitle("Offer Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - Achievement Detail Sheet

private struct AchievementDetailSheet: View {
    let achievement: Achievement
    let snapshot: AchievementSnapshot

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let unlocked = achievement.isUnlocked(snapshot)
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(AnchoredColors.border)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 24)

            // Badge
            ZStack {
                Circle()
                    .fill(unlocked ? AnyShapeStyle(achievement.gradient.linearGradient)
                                   : AnyShapeStyle(AnchoredColors.border))
                    .frame(width: 88, height: 88)
                Image(systemName: achievement.sfSymbol)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(unlocked ? .white : AnchoredColors.muted)
            }
            .padding(.bottom, 20)

            // Status pill
            Text(unlocked ? "Unlocked" : "Locked")
                .anchoredStyle(.label)
                .foregroundStyle(unlocked ? AnchoredColors.amber : AnchoredColors.muted)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    unlocked ? AnchoredColors.amber.opacity(0.12) : AnchoredColors.border.opacity(0.5)
                )
                .clipShape(Capsule())
                .padding(.bottom, 16)

            Text(achievement.title)
                .anchoredStyle(.h2)
                .foregroundStyle(AnchoredColors.navy)
                .padding(.bottom, 8)

            Text(achievement.description)
                .anchoredStyle(.body)
                .foregroundStyle(AnchoredColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(AnchoredColors.parchment.ignoresSafeArea())
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Preview

#Preview("Free user") {
    NavigationStack { ProfileView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}

#Preview("Premium") {
    NavigationStack { ProfileView() }
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.previewPremium)
        .modelContainer(PreviewContainer.shared)
}
