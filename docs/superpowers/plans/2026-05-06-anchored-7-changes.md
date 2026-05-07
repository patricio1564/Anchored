# Anchored 7-Change Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 7 coordinated changes — onboarding restructure with prayer step, subscription paywall with real pricing, notification time picker, visual overhaul, keyboard dismiss fix, ASV default translation, and dark mode switcher.

**Architecture:** The onboarding flow grows from 6 pages to 9, with reordered steps (notifications before verse recommender, paywall after prayer/praise). A new `AppearanceManager` handles light/dark mode. `PremiumManager` product IDs update to match App Store Connect. `BibleTranslation.isFree` flips from WEB to ASV.

**Tech Stack:** Swift 5.9, SwiftUI, SwiftData, StoreKit 2, UNUserNotificationCenter, XcodeGen

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `Anchored/Services/AppearanceManager.swift` | `@Observable` manager for light/dark/system preference via UserDefaults |

### Modified Files
| File | What changes |
|------|-------------|
| `Anchored/Features/Onboarding/OnboardingView.swift` | Full rewrite: 9-page flow, navy card styling, keyboard dismiss, notification page, prayer/praise pages, new paywall |
| `Anchored/Services/PremiumManager.swift` | Product IDs → `AnchoredWeekly`/`AnchoredYearly`, Plan enum `.monthly` → `.weekly` |
| `Anchored/Services/BibleAPIService.swift` | `isFree` flips: ASV=free, WEB=premium |
| `Anchored/Models/UserSettings.swift` | Default `preferredTranslation` → `"asv"` |
| `Anchored/App/AnchoredApp.swift` | Add `AppearanceManager`, apply `.preferredColorScheme()` |
| `Anchored/Features/Profile/ProfileView.swift` | Add appearance picker section, add reminder time picker row |

---

### Task 1: ASV Default Translation

**Files:**
- Modify: `Anchored/Services/BibleAPIService.swift:57`
- Modify: `Anchored/Models/UserSettings.swift:68`

- [ ] **Step 1: Update `isFree` in BibleTranslation**

In `Anchored/Services/BibleAPIService.swift`, change line 57:

```swift
// Old:
    var isFree: Bool { self == .web }

// New:
    /// ASV is the free default; all others are premium.
    var isFree: Bool { self == .asv }
```

Also update the file header comment (line 24) from `"WEB — World English Bible (public domain, default, FREE)"` to `"WEB — World English Bible (public domain, premium gate)"` and line 27 from `"ASV — American Standard Version (public domain, premium)"` to `"ASV — American Standard Version (public domain, default, FREE)"`.

- [ ] **Step 2: Update default translation in UserSettings**

In `Anchored/Models/UserSettings.swift`, change line 68:

```swift
// Old:
    init(
        preferredTranslation: String = "web",

// New:
    init(
        preferredTranslation: String = "asv",
```

Also update the doc comment on line 39-41:

```swift
// Old:
    /// Translation identifier — maps to bible-api.com query param.
    /// "web" (World English Bible) is the free default; ESV/KJV/ASV/BBE are
    /// gated behind premium.

// New:
    /// Translation identifier — maps to bible-api.com query param.
    /// "asv" (American Standard Version) is the free default; WEB/KJV/BBE/Darby
    /// are gated behind premium.
```

- [ ] **Step 3: Commit**

```bash
git add Anchored/Services/BibleAPIService.swift Anchored/Models/UserSettings.swift
git commit -m "feat: change default Bible translation from WEB to ASV

ASV becomes the sole free translation. WEB joins the premium tier.
Existing users keep their saved preference; only new installs default to ASV."
```

---

### Task 1b: Update Notification Content Strings

**Files:**
- Modify: `Anchored/Services/NotificationService.swift`

- [ ] **Step 1: Update notification title and body**

In `Anchored/Services/NotificationService.swift`, change lines 87-89:

```swift
// Old:
        let content = UNMutableNotificationContent()
        content.title = "Today's Verse"
        content.body = "Take a quiet moment. Your verse is waiting."

// New:
        let content = UNMutableNotificationContent()
        content.title = "Time to grow in the Word 📖"
        content.body = "Your daily verse and lessons are waiting for you."
```

- [ ] **Step 2: Update the header comment**

The file header (lines 7-20) says "We NEVER prompt for notification permission at launch." Since we now prompt during onboarding (page 3), update the relevant paragraph:

```swift
// Old:
// We NEVER prompt for notification permission at launch. First launch
// is a moment of curiosity — asking for a scary OS-level permission
// immediately breaks the spell. Instead, we prompt contextually:
//
//   • After the user manually enables "Daily reminder" in Profile.
//   • After the user completes their first lesson and sees the streak
//     celebration, if they tap "Remind me to come back tomorrow".

// New:
// We prompt for notification permission contextually, never with a
// raw system dialog at launch. Instead we ask at natural moments:
//
//   • During onboarding (page 3) when the user toggles "Enable daily reminder".
//   • After the user manually enables "Daily reminder" in Profile.
```

- [ ] **Step 3: Commit**

```bash
git add Anchored/Services/NotificationService.swift
git commit -m "feat: update daily reminder notification content to match spec"
```

---

### Task 2: PremiumManager — Update Product IDs and Plan Enum

**Files:**
- Modify: `Anchored/Services/PremiumManager.swift`

- [ ] **Step 1: Update product IDs and Plan enum**

In `Anchored/Services/PremiumManager.swift`, make these changes:

Lines 26-27 — product ID constants:
```swift
// Old:
    static let monthlyProductID = "com.anchored.app.premium.monthly"
    static let yearlyProductID  = "com.anchored.app.premium.yearly"

// New:
    static let weeklyProductID = "AnchoredWeekly"
    static let yearlyProductID = "AnchoredYearly"
```

Line 36 — Plan enum:
```swift
// Old:
    enum Plan { case monthly, yearly }

// New:
    enum Plan { case weekly, yearly }
```

Lines 44-45 — published products:
```swift
// Old:
    @Published private(set) var monthlyProduct: Product?
    @Published private(set) var yearlyProduct: Product?

// New:
    @Published private(set) var weeklyProduct: Product?
    @Published private(set) var yearlyProduct: Product?
```

Line 49 — convenience accessor:
```swift
// Old:
    var product: Product? { yearlyProduct ?? monthlyProduct }

// New:
    var product: Product? { yearlyProduct ?? weeklyProduct }
```

Lines 87-89 — purchase method:
```swift
// Old:
    func purchase(_ plan: Plan = .yearly) async {
        let product = plan == .yearly ? yearlyProduct : monthlyProduct

// New:
    func purchase(_ plan: Plan = .yearly) async {
        let product = plan == .yearly ? yearlyProduct : weeklyProduct
```

Lines 139-145 — fetchProducts:
```swift
// Old:
    private func fetchProducts() async {
        let ids = [Self.monthlyProductID, Self.yearlyProductID]
        guard let products = try? await Product.products(for: ids) else { return }
        for p in products {
            if p.id == Self.monthlyProductID { monthlyProduct = p }
            if p.id == Self.yearlyProductID  { yearlyProduct  = p }
        }
    }

// New:
    private func fetchProducts() async {
        let ids = [Self.weeklyProductID, Self.yearlyProductID]
        guard let products = try? await Product.products(for: ids) else { return }
        for p in products {
            if p.id == Self.weeklyProductID { weeklyProduct = p }
            if p.id == Self.yearlyProductID { yearlyProduct = p }
        }
    }
```

Lines 152 — checkEntitlements knownIDs:
```swift
// Old:
            let knownIDs = [Self.monthlyProductID, Self.yearlyProductID]

// New:
            let knownIDs = [Self.weeklyProductID, Self.yearlyProductID]
```

Update the file header comments (lines 11-15) to reflect weekly/yearly instead of monthly/yearly.

- [ ] **Step 2: Commit**

```bash
git add Anchored/Services/PremiumManager.swift
git commit -m "feat: update StoreKit product IDs to AnchoredWeekly/AnchoredYearly

Replace monthly plan with weekly. Product IDs match App Store Connect configuration."
```

---

### Task 3: AppearanceManager — New File

**Files:**
- Create: `Anchored/Services/AppearanceManager.swift`

- [ ] **Step 1: Create AppearanceManager**

Create `Anchored/Services/AppearanceManager.swift`:

```swift
//
//  AppearanceManager.swift
//  Anchored
//
//  Manages the user's light/dark/system appearance preference.
//  Stored in UserDefaults and applied via .preferredColorScheme()
//  on the root view.
//

import SwiftUI

@Observable
@MainActor
final class AppearanceManager {

    enum Mode: String, CaseIterable {
        case system, light, dark

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }

    private static let key = "appearanceMode"

    var mode: Mode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Self.key) }
    }

    /// Returns nil for system (no override), or the explicit scheme.
    var colorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key) ?? "system"
        self.mode = Mode(rawValue: saved) ?? .system
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Anchored/Services/AppearanceManager.swift
git commit -m "feat: add AppearanceManager for light/dark/system mode"
```

---

### Task 4: Wire AppearanceManager into AnchoredApp

**Files:**
- Modify: `Anchored/App/AnchoredApp.swift`

- [ ] **Step 1: Add AppearanceManager and apply preferredColorScheme**

In `Anchored/App/AnchoredApp.swift`, add the state property after line 54:

```swift
// Old (lines 53-54):
    @StateObject private var authManager = AuthManager()
    @StateObject private var premiumManager = PremiumManager()

// New:
    @StateObject private var authManager = AuthManager()
    @StateObject private var premiumManager = PremiumManager()
    @State private var appearanceManager = AppearanceManager()
```

Update the body (lines 58-66):

```swift
// Old:
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(premiumManager)
                .tint(AnchoredColors.amber)
        }
        .modelContainer(modelContainer)
    }

// New:
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(premiumManager)
                .environment(appearanceManager)
                .preferredColorScheme(appearanceManager.colorScheme)
                .tint(AnchoredColors.amber)
        }
        .modelContainer(modelContainer)
    }
```

- [ ] **Step 2: Commit**

```bash
git add Anchored/App/AnchoredApp.swift
git commit -m "feat: wire AppearanceManager into root view for dark mode support"
```

---

### Task 5: ProfileView — Add Appearance Picker and Reminder Time Picker

**Files:**
- Modify: `Anchored/Features/Profile/ProfileView.swift`

- [ ] **Step 1: Add appearance manager environment and time state**

At the top of `ProfileView` struct, add the environment property alongside the existing ones:

```swift
@Environment(AppearanceManager.self) private var appearanceManager
```

- [ ] **Step 2: Add appearance row to settingsSection**

In the `settingsSection` computed property (around line 347), insert an appearance row before the translation row. Change:

```swift
// Old:
            VStack(spacing: 0) {
                translationRow
                Divider().background(AnchoredColors.border)
                fontSizeRow

// New:
            VStack(spacing: 0) {
                appearanceRow
                Divider().background(AnchoredColors.border)
                translationRow
                Divider().background(AnchoredColors.border)
                fontSizeRow
```

- [ ] **Step 3: Add the appearanceRow computed property**

Add this after the `translationRow` definition (around line 405):

```swift
    private var appearanceRow: some View {
        settingRow {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
                .foregroundStyle(AnchoredColors.navy)
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
```

- [ ] **Step 4: Add reminder time picker row**

After the `reminderRow` definition, add a conditional time picker that shows when the reminder is enabled. In `settingsSection`, change:

```swift
// Old:
                reminderRow
                if notificationStatus == .denied {

// New:
                reminderRow
                if isReminderOn {
                    Divider().background(AnchoredColors.border)
                    reminderTimeRow
                }
                if notificationStatus == .denied {
```

Then add the `reminderTimeRow` computed property near the other settings rows:

```swift
    private var reminderTimeRow: some View {
        settingRow {
            Label("Reminder time", systemImage: "clock.fill")
                .foregroundStyle(AnchoredColors.navy)
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
            .tint(AnchoredColors.amber)
        }
    }

    private var defaultReminderDate: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
```

- [ ] **Step 5: Commit**

```bash
git add Anchored/Features/Profile/ProfileView.swift
git commit -m "feat: add appearance picker and reminder time picker to Profile settings"
```

---

### Task 6: Rewrite OnboardingView — Full 9-Page Flow

**Files:**
- Modify: `Anchored/Features/Onboarding/OnboardingView.swift`

This is the largest task. The entire file is rewritten to support:
- 9 pages (0-8) with reordered flow
- Navy card backgrounds with amber headlines and parchment body text
- Notification page with time picker (page 3)
- Keyboard dismissal via @FocusState on verse recommender (page 4)
- Prayer page with LLM/fallback generation (page 5)
- Praise page with confetti and +100 XP (page 6)
- New subscription paywall with weekly/yearly pricing and Apple disclosures (page 7)
- Sign in (page 8)

- [ ] **Step 1: Replace the full OnboardingView.swift file**

Replace the entire contents of `Anchored/Features/Onboarding/OnboardingView.swift` with the new implementation. The file is ~950 lines. Key structural changes:

**State properties to add:**
```swift
@State private var page: Int = 0
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

// Prayer state (pages 5-6)
@State private var prayerText: String = ""
@State private var prayerLoading: Bool = false
@State private var didPray: Bool = false
@State private var showConfetti: Bool = false
@State private var xpScale: CGFloat = 0.5

// Subscription state (page 7)
@State private var selectedPlan: PremiumManager.Plan = .yearly
```

**Total pages constant:**
```swift
private let totalPages = 9
```

**TabView body with all 9 pages:**
```swift
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
```

**Next button visibility:** Hidden on pages 5 (prayer has its own Amen/Skip), 6 (praise has Continue), 7 (subscription has own buttons), and 8 (sign-in):
```swift
if page < 5 {
    nextButton
        .screenPadding()
        .padding(.bottom, 24)
}
```

**Next button labels:**
```swift
Text(page == 3 && notificationsAccepted ? "Set reminder" :
     page == 3 ? "Continue" :
     page == 4 ? "Continue" : "Continue")
```

**nextEnabled logic:**
```swift
private var nextEnabled: Bool {
    switch page {
    case 1: return !selectedGoals.isEmpty
    case 2: return !selectedExperience.isEmpty
    case 4: return demoPhase != .idle // must have fetched a verse before continuing
    default: return true
    }
}
```

**Next button action for page 3 (notifications):**
When advancing from page 3, if notifications were accepted, save the time and schedule:
```swift
Button {
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
    if page == 4 {
        isFeelingFieldFocused = false
        // Start loading prayer for next page
        Task { await generatePrayer() }
    }
    withAnimation { page += 1 }
} label: { ... }
```

**Visual overhaul — onboarding card modifier:**

Add a helper modifier for consistent navy card styling across all pages:

```swift
private func onboardingCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 16, content: content)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnchoredColors.navy)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
}
```

Use `AnchoredColors.amber` for headlines, `AnchoredColors.parchment` for body text, and `AnchoredColors.amber` for SF Symbols inside all onboarding cards.

**Page 3 — Notification page:**
```swift
private var notificationPage: some View {
    VStack(spacing: 20) {
        Spacer(minLength: 20)
        onboardingCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(AnchoredColors.amber).frame(width: 44, height: 44)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AnchoredColors.navy)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stay rooted in the Word")
                        .anchoredStyle(.h3)
                        .foregroundStyle(AnchoredColors.amber)
                    Text("Get a gentle daily reminder to read and learn.")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.parchment)
                }
            }

            Toggle(isOn: $notificationsAccepted) {
                Text("Enable daily reminder")
                    .anchoredStyle(.bodyMd)
                    .foregroundStyle(AnchoredColors.parchment)
            }
            .tint(AnchoredColors.amber)
            .onChange(of: notificationsAccepted) { _, accepted in
                if accepted {
                    Task { _ = await NotificationService.shared.requestAuthorization() }
                }
            }

            if notificationsAccepted {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What time works best?")
                        .anchoredStyle(.bodyMd)
                        .foregroundStyle(AnchoredColors.amber)
                    DatePicker("", selection: $reminderDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark) // ensures wheel is visible on navy bg
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .screenPadding()
        Spacer(minLength: 20)
    }
}
```

**Page 4 — Verse recommender with keyboard dismiss:**

The TextEditor gets `.focused($isFeelingFieldFocused)` added. In the "Find verses" button action, before running the recommender:
```swift
isFeelingFieldFocused = false
```

All card backgrounds change to navy, text to amber/parchment.

**Page 5 — Prayer page:**
```swift
private var prayerPage: some View {
    VStack(spacing: 20) {
        Spacer(minLength: 20)
        onboardingCard {
            HStack(spacing: 8) {
                Text("🙏").font(.title)
                Text("Let's Talk to God")
                    .anchoredStyle(.h2)
                    .foregroundStyle(AnchoredColors.amber)
            }

            if prayerLoading {
                VStack(spacing: 12) {
                    ProgressView().tint(AnchoredColors.amber)
                    Text("Preparing a prayer for you...")
                        .anchoredStyle(.body)
                        .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                Text(prayerText)
                    .anchoredStyle(.scripture)
                    .foregroundStyle(AnchoredColors.parchment)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Take a moment to pray this to the Lord")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
            }
        }
        .screenPadding()

        VStack(spacing: 12) {
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

            Button {
                withAnimation { page = 7 } // skip to subscription
            } label: {
                Text("Skip")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .screenPadding()
        Spacer(minLength: 20)
    }
}
```

**Prayer generation method:**
```swift
@MainActor
private func generatePrayer() async {
    guard case .done(let rec) = demoPhase, let verse = rec.verses.first else {
        prayerText = "Lord, thank You for meeting me right where I am. Help me hold onto Your Word today and find peace in Your presence. Amen."
        return
    }
    prayerLoading = true
    // Use the curated prayer from the verse recommendation (always available)
    prayerText = verse.prayer
    prayerLoading = false
}
```

**Page 6 — Praise page:**
```swift
private var praisePage: some View {
    VStack(spacing: 28) {
        Spacer(minLength: 40)

        ZStack {
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AnchoredColors.amber.opacity(0.14))
                        .frame(width: 120, height: 120)
                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(AnchoredColors.amber)
                }

                Text("God heard every word.")
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.amber)
                    .multilineTextAlignment(.center)

                Text("+100 XP")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AnchoredColors.amber)
                    .scaleEffect(xpScale)
            }
        }

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
    .onAppear {
        // Award XP
        let streakManager = StreakManager(modelContext: modelContext)
        streakManager.awardXP(100)
        // Animate
        showConfetti = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            xpScale = 1.0
        }
    }
}
```

**ConfettiView — simple Canvas-based particle animation:**
```swift
private struct ConfettiView: View {
    @State private var particles: [(x: CGFloat, y: CGFloat, color: Color, size: CGFloat, speed: CGFloat)] = []
    @State private var timer: Timer?

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
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
        let colors: [Color] = [AnchoredColors.amber, .yellow, .orange, .white, AnchoredColors.amber.opacity(0.6)]
        particles = (0..<60).map { _ in
            (x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
             y: CGFloat.random(in: -200...(-20)),
             color: colors.randomElement()!,
             size: CGFloat.random(in: 4...8),
             speed: CGFloat.random(in: 2...5))
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].speed
                particles[i].x += CGFloat.random(in: -1...1)
            }
        }
    }
}
```

**Page 7 — New subscription paywall:**
```swift
private var subscriptionPage: some View {
    ScrollView {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(AnchoredColors.amber)
                Text("Unlock Anchored Premium")
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.amber)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            // Feature list
            onboardingCard {
                featureRow(icon: "book.fill", text: "All 35 topics & 176 lessons")
                featureRow(icon: "globe", text: "5 Bible translations")
                featureRow(icon: "sparkles", text: "Verse Recommender")
                featureRow(icon: "arrow.down.circle.fill", text: "All future content")
            }
            .screenPadding()

            // Plan cards
            HStack(spacing: 12) {
                weeklyPlanCard
                yearlyPlanCard
            }
            .screenPadding()

            // Subscribe button
            Button {
                Task { await premiumManager.purchase(selectedPlan) }
            } label: {
                HStack(spacing: 8) {
                    if premiumManager.purchaseState == .purchasing {
                        ProgressView().tint(.white)
                    }
                    Text("Subscribe")
                        .anchoredStyle(.bodyMd)
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(AnchoredColors.amber)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(premiumManager.purchaseState == .purchasing)
            .screenPadding()

            // Apple disclosures
            VStack(spacing: 6) {
                Text("Payment will be charged to your Apple Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Text("·").foregroundStyle(AnchoredColors.parchment.opacity(0.5))
                    Link("Privacy Policy", destination: URL(string: "https://patricio1564.github.io/Anchored/privacy-policy")!)
                }
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.amber)
            }
            .screenPadding()

            // Restore + Skip
            Button { Task { await premiumManager.restorePurchases() } } label: {
                Text("Restore Purchases")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.amber)
            }
            .buttonStyle(.plain)

            Button { withAnimation { page = 8 } } label: {
                Text("Continue with Free")
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.5))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
    }
}

private func featureRow(icon: String, text: String) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(AnchoredColors.amber)
            .frame(width: 24)
        Text(text)
            .anchoredStyle(.body)
            .foregroundStyle(AnchoredColors.parchment)
        Spacer()
        Image(systemName: "checkmark")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AnchoredColors.amber)
    }
}

private var weeklyPlanCard: some View {
    Button { selectedPlan = .weekly } label: {
        VStack(alignment: .leading, spacing: 8) {
            Text("WEEKLY")
                .anchoredStyle(.label)
                .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
            Text(premiumManager.weeklyProduct?.displayPrice ?? "$0.99")
                .anchoredStyle(.xpDigit)
                .foregroundStyle(AnchoredColors.parchment)
            Text("/ week")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnchoredColors.navy)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(selectedPlan == .weekly ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.2), lineWidth: selectedPlan == .weekly ? 2 : 1)
        )
    }
    .buttonStyle(.plain)
}

private var yearlyPlanCard: some View {
    Button { selectedPlan = .yearly } label: {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("YEARLY")
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.parchment.opacity(0.7))
                Spacer()
                Text("Best Value")
                    .anchoredStyle(.caption)
                    .foregroundStyle(AnchoredColors.navy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AnchoredColors.amber)
                    .clipShape(Capsule())
            }
            Text(premiumManager.yearlyProduct?.displayPrice ?? "$29.99")
                .anchoredStyle(.xpDigit)
                .foregroundStyle(AnchoredColors.parchment)
            Text("/ year")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.parchment.opacity(0.6))
            Text("Save 42%")
                .anchoredStyle(.caption)
                .foregroundStyle(AnchoredColors.amber)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnchoredColors.navy)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(selectedPlan == .yearly ? AnchoredColors.amber : AnchoredColors.parchment.opacity(0.2), lineWidth: selectedPlan == .yearly ? 2 : 1)
        )
    }
    .buttonStyle(.plain)
}
```

**Page 8 — Sign-in (page number change only):**
Same as current page 5 but with updated page references.

**ensureSettingsRow helper** (shared with saveOnboardingAnswers):
```swift
private func ensureSettingsRow() -> UserSettings {
    if let existing = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
        return existing
    }
    let fresh = UserSettings()
    modelContext.insert(fresh)
    return fresh
}
```

**Background:** The overall ZStack background changes from `AnchoredColors.parchment` to a dark gradient:
```swift
Color(red: 0.08, green: 0.06, blue: 0.05).ignoresSafeArea()
```

**Branding bar and progress dots:** Text and dots switch to amber/parchment to be visible on dark background.

- [ ] **Step 2: Build and verify the file compiles**

Run `xcodegen generate` then open Xcode and build (⌘B).

- [ ] **Step 3: Commit**

```bash
git add Anchored/Features/Onboarding/OnboardingView.swift
git commit -m "feat: rewrite onboarding — 9-page flow with prayer step, paywall, navy cards

New flow: Welcome → Goals → Experience → Notifications (with time picker)
→ Verse Recommender → Prayer → Praise (+100 XP) → Subscription → Sign In.
Navy card backgrounds with amber headlines and parchment body text.
Keyboard dismisses via @FocusState before verse display.
Weekly/yearly subscription with Apple disclosures, ToS + Privacy links."
```

---

### Task 7: Regenerate xcodeproj and Final Verification

**Files:**
- Regenerate: `Anchored.xcodeproj`

- [ ] **Step 1: Run xcodegen to sync new file**

```bash
cd /Users/patrickray/Downloads/Anchored-merged
xcodegen generate
```

Expected: "Created project at .../Anchored.xcodeproj"

- [ ] **Step 2: Build in Xcode**

Open `Anchored.xcodeproj` and press ⌘B. Fix any compile errors.

- [ ] **Step 3: Run through verification checklist**

Walk through all 17 items from the spec's verification checklist in the Simulator:
1. Build succeeds
2. Onboarding flow order is correct (9 pages)
3. Navy cards with amber/parchment text
4. Keyboard dismisses on "Continue" after typing feeling
5. Notification page shows time picker when enabled
6. Prayer page shows after verse
7. "Amen" → confetti + 100 XP
8. "Skip" → subscription (no XP)
9. Paywall shows weekly/yearly pricing
10. Apple disclosures present
11. ASV is default for new installs
12. ASV is free, others premium
13. Profile has Appearance picker
14. Dark mode toggle works
15. Profile has reminder time picker
16. Dark mode colors are warm
17. Previews render

- [ ] **Step 4: Commit regenerated xcodeproj**

```bash
git add Anchored.xcodeproj/project.pbxproj Anchored/Services/AppearanceManager.swift
git commit -m "chore: regenerate xcodeproj with AppearanceManager"
```

- [ ] **Step 5: Push to main**

```bash
git push origin main
```
