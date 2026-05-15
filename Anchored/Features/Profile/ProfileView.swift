import SwiftUI
import SwiftData
import UserNotifications

struct ProfileView: View {

    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.modelContext) private var modelContext
    @Environment(AppearanceManager.self) private var appearanceManager

    @State private var streak: StreakManager?
    @Query private var progressRows: [LessonProgress]
    @Query private var settingsRows: [UserSettings]

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isReminderOn: Bool = false
    @State private var reminderHour: Int = 8
    @State private var reminderMinute: Int = 0

    @State private var showSignOutConfirm = false
    @State private var showResetConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showPostDeleteSIWAHint = false
    @State private var deleteErrorMessage: String?
    @State private var selectedAchievement: Achievement?
    @State private var isRestoring = false
    @State private var showOfferCodeSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Display title
                Text("Profile")
                    .font(.custom("Newsreader", size: 36).weight(.regular))
                    .tracking(-0.72)
                    .foregroundStyle(AnchoredColors.ink)
                    .padding(.bottom, 2)

                header
                statsGrid
                levelCard
                subscriptionSection
                achievementsSection
                settingsSection
                signOutButton
                legalLinks
                deleteAccountButton
                Spacer(minLength: 120)
            }
            .padding(.top, 58)
            .padding(.bottom, 24)
            .screenPadding()
        }
        .appBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
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
        .alert("Delete Account?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { deleteAccount() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your progress, streak, notes, prayers, and saved verses on this device and from iCloud. This cannot be undone.")
        }
        .alert("Revoke Apple ID access?", isPresented: $showPostDeleteSIWAHint) {
            Button("Open Settings") { openAppleIDSettings() }
            Button("Done", role: .cancel) {}
        } message: {
            Text("Anchored has been deleted from this device. To fully revoke Anchored's access to your Apple ID, open Settings \u{2192} Apple ID \u{2192} Sign-In & Security \u{2192} Apps Using Apple ID.")
        }
        .alert("Couldn\u{2019}t delete account", isPresented: Binding(
            get: { deleteErrorMessage != nil },
            set: { if !$0 { deleteErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { deleteErrorMessage = nil }
        } message: {
            Text(deleteErrorMessage ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            // Avatar with gradient + initials
            ZStack {
                Circle()
                    .fill(AnchoredColors.gradientPrimary)
                    .frame(width: 64, height: 64)
                    .shadow(color: AnchoredColors.coral.opacity(0.35), radius: 11, x: 0, y: 8)
                Text(initials)
                    .font(.custom("Newsreader", size: 24).weight(.medium))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.custom("Newsreader", size: 22).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                HStack(spacing: 4) {
                    if premiumManager.isPremium {
                        Text("\u{2605} PREMIUM")
                            .font(.custom("Outfit", size: 12).weight(.semibold))
                            .tracking(0.48)
                            .foregroundStyle(AnchoredColors.coral)
                    }
                    if let streak {
                        Text(premiumManager.isPremium ? "\u{00B7} " : "")
                            .foregroundStyle(AnchoredColors.coral) +
                        Text(streak.levelTitle.uppercased())
                            .font(.custom("Outfit", size: 12).weight(.semibold))
                            .tracking(0.48)
                            .foregroundStyle(AnchoredColors.coral)
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - Stats

    private var statsGrid: some View {
        HStack(spacing: 8) {
            statTile(icon: "flame.fill", tint: AnchoredColors.coral,
                     value: "\(streak?.currentStreak ?? 0)", label: "Streak")
            statTile(icon: "trophy.fill", tint: AnchoredColors.gold,
                     value: "\(streak?.longestStreak ?? 0)", label: "Best")
            statTile(icon: "book.fill", tint: AnchoredColors.blue,
                     value: "\(completedLessonsCount)", label: "Lessons")
        }
    }

    private func statTile(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
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

    // MARK: - Level / XP

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Level \(streak?.level ?? 1)")
                    .font(.custom("Newsreader", size: 18).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
                Spacer()
                Text((streak?.levelTitle ?? "Seeker").uppercased())
                    .font(.custom("Outfit", size: 11).weight(.bold))
                    .tracking(0.66)
                    .foregroundStyle(AnchoredColors.coral)
            }
            .padding(.bottom, 10)

            if let streak {
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

                Text("\(streak.xpForCurrentLevel - streak.xpInCurrentLevel) XP to \(nextLevelTitle)")
                    .font(.custom("Outfit", size: 12).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .padding(.top, 8)
            }
        }
        .glassCard(padding: 18, cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AnchoredColors.gold.opacity(0.13))
                        .frame(width: 32, height: 32)
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AnchoredColors.gold)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unlock Premium")
                        .font(.custom("Outfit", size: 14.5).weight(.semibold))
                        .foregroundStyle(AnchoredColors.ink)
                    Text("All translations, verse highlights, and more.")
                        .font(.custom("Outfit", size: 12).weight(.medium))
                        .foregroundStyle(AnchoredColors.inkSoft)
                }
                Spacer()
                Button {
                    premiumManager.presentPaywall()
                } label: {
                    Text("Upgrade")
                        .font(.custom("Outfit", size: 11).weight(.semibold))
                        .tracking(0.44)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AnchoredColors.gradientPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Button {
                showOfferCodeSheet = true
            } label: {
                Text("Have an offer code?")
                    .font(.custom("Outfit", size: 12).weight(.medium))
                    .foregroundStyle(AnchoredColors.coral)
            }
            .buttonStyle(.plain)
        }
        .glassCard(padding: 16, cornerRadius: 20)
    }

    private var premiumActiveCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AnchoredColors.coral)
                Text("Premium Active")
                    .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    .foregroundStyle(AnchoredColors.ink)
                Spacer()
            }
            HStack(spacing: 10) {
                Button {
                    guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
                    #if canImport(UIKit)
                    UIApplication.shared.open(url)
                    #endif
                } label: {
                    Text("MANAGE")
                        .font(.custom("Outfit", size: 11).weight(.semibold))
                        .tracking(0.44)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(AnchoredColors.glass)
                        .foregroundStyle(AnchoredColors.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AnchoredColors.line, lineWidth: 1))
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
                            ProgressView().tint(AnchoredColors.ink)
                        } else {
                            Text("RESTORE")
                                .font(.custom("Outfit", size: 11).weight(.semibold))
                                .tracking(0.44)
                                .foregroundStyle(AnchoredColors.ink)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(AnchoredColors.glass)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AnchoredColors.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(isRestoring)
            }
        }
        .glassCard(padding: 16, cornerRadius: 20)
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.custom("Newsreader", size: 18).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                      spacing: 10) {
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
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            unlocked
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color(hex: achievement.gradient.hexStops.start),
                                             Color(hex: achievement.gradient.hexStops.start).opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                              )
                            : AnyShapeStyle(Color.white.opacity(0.5))
                        )
                        .frame(width: 46, height: 46)
                        .overlay(
                            Group {
                                if !unlocked {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(AnchoredColors.line, lineWidth: 1)
                                }
                            }
                        )
                        .shadow(
                            color: unlocked ? Color(hex: achievement.gradient.hexStops.start).opacity(0.3) : .clear,
                            radius: 7, x: 0, y: 6
                        )
                    Image(systemName: achievement.sfSymbol)
                        .font(.system(size: 20))
                        .foregroundStyle(unlocked ? .white : AnchoredColors.inkMute)
                }
                Text(achievement.title)
                    .font(.custom("Outfit", size: 10).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
            .frame(maxWidth: .infinity)
            .opacity(unlocked ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(achievement.title). \(unlocked ? "Unlocked." : "Locked.") \(achievement.description)")
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.custom("Newsreader", size: 18).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)

            VStack(spacing: 0) {
                appearanceRow
                Divider().overlay(AnchoredColors.lineSoft)
                translationRow
                Divider().overlay(AnchoredColors.lineSoft)
                fontSizeRow
                Divider().overlay(AnchoredColors.lineSoft)
                reminderRow
                if isReminderOn {
                    Divider().overlay(AnchoredColors.lineSoft)
                    reminderTimeRow
                }
                if notificationStatus == .denied {
                    Divider().overlay(AnchoredColors.lineSoft)
                    openSettingsRow
                }
                #if DEBUG
                Divider().overlay(AnchoredColors.lineSoft)
                debugPremiumRow
                Divider().overlay(AnchoredColors.lineSoft)
                resetRow
                #endif
            }
            .glassCard(padding: 0, cornerRadius: 20)
        }
    }

    private var appearanceRow: some View {
        settingRow {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
        } trailing: {
            @Bindable var manager = appearanceManager
            Picker("", selection: $manager.mode) {
                ForEach(AppearanceManager.Mode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
    }

    private var translationRow: some View {
        settingRow {
            Label("Translation", systemImage: "globe")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
        } trailing: {
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
            .tint(AnchoredColors.coral)
        }
    }

    private var fontSizeRow: some View {
        settingRow {
            Label("Font size", systemImage: "textformat.size")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
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
            .tint(AnchoredColors.coral)
        }
    }

    private var reminderRow: some View {
        settingRow {
            Label("Daily reminder", systemImage: "bell.fill")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
        } trailing: {
            Toggle("", isOn: Binding(
                get: { isReminderOn },
                set: { newValue in Task { await setReminder(enabled: newValue) } }
            ))
            .labelsHidden()
            .tint(AnchoredColors.coral)
        }
    }

    private var reminderTimeRow: some View {
        settingRow {
            Label("Reminder time", systemImage: "clock.fill")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
        } trailing: {
            DatePicker("", selection: Binding(
                get: {
                    let row = settingsRows.first
                    let time = row?.dailyReminderTime ?? "08:00"
                    let parts = time.split(separator: ":").compactMap { Int($0) }
                    guard parts.count == 2 else { return defaultReminderDate }
                    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                    comps.hour = parts[0]
                    comps.minute = parts[1]
                    return Calendar.current.date(from: comps) ?? defaultReminderDate
                },
                set: { newDate in
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    let hour = comps.hour ?? 8
                    let minute = comps.minute ?? 0
                    let row = ensureSettingsRow()
                    row.dailyReminderTime = String(format: "%02d:%02d", hour, minute)
                    try? modelContext.save()
                    Task {
                        _ = await NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
                    }
                }
            ), displayedComponents: .hourAndMinute)
            .labelsHidden()
            .tint(AnchoredColors.coral)
        }
    }

    private var defaultReminderDate: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }

    private var openSettingsRow: some View {
        Button {
            openSystemSettings()
        } label: {
            settingRow {
                Label("Open iOS Settings", systemImage: "arrow.up.right.square")
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                    .foregroundStyle(AnchoredColors.coral)
            } trailing: {
                Text("Notifications denied")
                    .font(.custom("Outfit", size: 12).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
            }
        }
        .buttonStyle(.plain)
    }

    #if DEBUG
    private var debugPremiumRow: some View {
        settingRow {
            Label("Debug: Premium", systemImage: "hammer.fill")
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.inkMute)
        } trailing: {
            Toggle("", isOn: Binding(
                get: { premiumManager.isPremium },
                set: { $0 ? premiumManager.debugUnlock() : premiumManager.debugLock() }
            ))
            .labelsHidden()
            .tint(AnchoredColors.coral)
        }
    }

    private var resetRow: some View {
        Button {
            showResetConfirm = true
        } label: {
            settingRow {
                Label("Reset progress", systemImage: "arrow.counterclockwise")
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
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
            Spacer()
            trailing()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Sign out

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            Text("Sign out")
                .font(.custom("Outfit", size: 14.5).weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(AnchoredColors.error)
                .background(AnchoredColors.glass)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AnchoredColors.line, lineWidth: 1)
                )
        }
    }

    // MARK: - Legal

    private var legalLinks: some View {
        HStack(spacing: 0) {
            Link("Privacy Policy", destination: URL(string: "https://patricio1564.github.io/Anchored/privacy-policy")!)
            Text(" \u{00B7} ")
                .foregroundStyle(AnchoredColors.inkMute)
            Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
        .font(.custom("Outfit", size: 13).weight(.medium))
        .tint(AnchoredColors.inkSoft)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Delete account

    private var deleteAccountButton: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            Text("Delete Account")
                .font(.custom("Outfit", size: 14.5).weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(AnchoredColors.error)
                .background(AnchoredColors.glass)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AnchoredColors.line, lineWidth: 1)
                )
        }
        .accessibilityHint("Permanently deletes your account and all of your data.")
    }

    private func deleteAccount() {
        do {
            try authManager.deleteAccount(context: modelContext)
            showPostDeleteSIWAHint = true
        } catch {
            deleteErrorMessage = "Something went wrong while deleting your data. Please try again. (\(error.localizedDescription))"
        }
    }

    private func openAppleIDSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }

    // MARK: - Bootstrap

    private func bootstrap() async {
        if streak == nil {
            let userId = authManager.currentUserId ?? "local-user"
            streak = StreakManager(modelContext: modelContext, userId: userId)
        }
        let status = await NotificationService.shared.currentAuthorizationStatus()
        let scheduled = await NotificationService.shared.isDailyReminderScheduled()
        notificationStatus = status
        isReminderOn = (status == .authorized || status == .provisional) && scheduled
        if let hm = currentReminderHHMM, let parsed = parseHHMM(hm) {
            reminderHour = parsed.hour
            reminderMinute = parsed.minute
        }
    }

    // MARK: - Settings mutations

    private func ensureSettingsRow() -> UserSettings {
        if let existing = settingsRows.first { return existing }
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

    private func setReminder(enabled: Bool) async {
        if enabled {
            var status = notificationStatus
            if status == .notDetermined {
                _ = await NotificationService.shared.requestAuthorization()
                status = await NotificationService.shared.currentAuthorizationStatus()
                notificationStatus = status
            }
            guard status == .authorized || status == .provisional else {
                isReminderOn = false
                return
            }
            let ok = await NotificationService.shared.scheduleDailyReminder(
                hour: reminderHour, minute: reminderMinute
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
           let value = BibleTranslation(rawValue: raw) { return value }
        return .web
    }

    private var currentFontSize: FontSizeScale {
        settingsRows.first?.fontSize ?? .medium
    }

    private var currentReminderHHMM: String? {
        settingsRows.first?.dailyReminderTime
    }

    private var nextLevelTitle: String {
        let titles = ["Seeker", "Disciple", "Scholar", "Teacher", "Elder", "Shepherd"]
        let level = streak?.level ?? 1
        return level < titles.count ? titles[level] : "Shepherd"
    }

    private func parseHHMM(_ s: String) -> (hour: Int, minute: Int)? {
        let parts = s.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    private func buildSnapshot() -> AchievementSnapshot {
        let lessonResults = progressRows
            .filter(\.completed)
            .map { AchievementSnapshot.LessonResult(
                lessonID: $0.lessonId, topicID: $0.topicId, score: $0.score
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
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AnchoredColors.coral.opacity(0.13))
                        .frame(width: 64, height: 64)
                    Image(systemName: "ticket.fill")
                        .foregroundStyle(AnchoredColors.coral)
                        .font(.system(size: 26))
                }
                .padding(.top, 8)

                Text("Redeem Offer Code")
                    .font(.custom("Newsreader", size: 22).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)

                Text("Enter your code to unlock Anchored Premium.")
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                    .foregroundStyle(AnchoredColors.inkSoft)
                    .multilineTextAlignment(.center)

                TextField("e.g. ANCHORED-BETA", text: $code)
                    .font(.custom("Outfit", size: 14.5).weight(.medium))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(AnchoredColors.glass)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AnchoredColors.line, lineWidth: 1)
                    )

                if let result {
                    switch result {
                    case .success:
                        Label("Premium unlocked!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    case .invalid:
                        Label("Invalid code. Please try again.", systemImage: "xmark.circle.fill")
                            .foregroundStyle(AnchoredColors.error)
                            .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    case .alreadyRedeemed:
                        Label("A code has already been redeemed on this device.", systemImage: "info.circle.fill")
                            .foregroundStyle(AnchoredColors.inkSoft)
                            .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    }
                }

                DawnButton(label: "Redeem", disabled: code.isEmpty) {
                    let r = premiumManager.redeemOfferCode(code)
                    result = r
                    if r == .success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            isPresented = false
                        }
                    }
                }

                Spacer()
            }
            .screenPadding()
            .background(AnchoredColors.backgroundGradient.ignoresSafeArea())
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
            Capsule()
                .fill(AnchoredColors.line)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 24)

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        unlocked
                        ? AnyShapeStyle(achievement.gradient.linearGradient)
                        : AnyShapeStyle(AnchoredColors.line)
                    )
                    .frame(width: 88, height: 88)
                    .shadow(
                        color: unlocked ? Color(hex: achievement.gradient.hexStops.start).opacity(0.3) : .clear,
                        radius: 12, x: 0, y: 8
                    )
                Image(systemName: achievement.sfSymbol)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(unlocked ? .white : AnchoredColors.inkMute)
            }
            .padding(.bottom, 20)

            Text(unlocked ? "UNLOCKED" : "LOCKED")
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .foregroundStyle(unlocked ? AnchoredColors.coral : AnchoredColors.inkMute)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    unlocked ? AnchoredColors.coral.opacity(0.12) : AnchoredColors.line
                )
                .clipShape(Capsule())
                .padding(.bottom, 16)

            Text(achievement.title)
                .font(.custom("Newsreader", size: 22).weight(.medium))
                .foregroundStyle(AnchoredColors.ink)
                .padding(.bottom, 8)

            Text(achievement.description)
                .font(.custom("Outfit", size: 14.5).weight(.medium))
                .foregroundStyle(AnchoredColors.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(AnchoredColors.backgroundGradient.ignoresSafeArea())
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
