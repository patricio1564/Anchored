# Anchored

A warm, modern Bible learning iOS app. Built with SwiftUI and SwiftData, iOS 17+.

This drop merges **Layer 1 (scaffold)** and **Layer 2 (content + services)** and fills in the six feature views (Onboarding, Home, Topics, Bible, Journal, Profile) so the app runs end-to-end with real data.

---

## What's in here

```
Anchored/
├── App/                       # Entry point, root, tab bar
│   ├── AnchoredApp.swift
│   ├── RootView.swift
│   └── MainTabView.swift
├── Content/                   # Curriculum + curated content (Layer 2)
│   ├── TopicCatalog.swift               # Types + gradient enum + lookup helpers
│   ├── GeneratedData/
│   │   └── TopicsCatalog+Generated.swift   # 35 topics, 176 lessons, 529 questions
│   ├── DailyVerses.swift                # 28-verse curated pool, day-of-year cycle
│   ├── FeelingMap.swift                 # 8 feelings × curated verses + prayers
│   └── Achievements.swift               # 8 badges with pure-function unlocks
├── Features/                  # One folder per top-level screen
│   ├── Bible/BibleView.swift
│   ├── Home/HomeView.swift
│   ├── Journal/JournalView.swift
│   ├── Onboarding/OnboardingView.swift
│   ├── Profile/ProfileView.swift
│   ├── Topics/TopicsView.swift
│   └── Shared/PlaceholderView.swift     # Used for not-yet-built detail screens
├── Models/                    # SwiftData @Model types
│   ├── BibleNote.swift
│   ├── LessonProgress.swift
│   ├── Prayer.swift
│   ├── SavedVerse.swift
│   ├── UserSettings.swift
│   └── UserStreak.swift
├── Services/                  # Singletons, managers, auth, persistence helpers
│   ├── AuthManager.swift                # Sign in with Apple stub
│   ├── PremiumManager.swift             # StoreKit 2 hook-up + paywall trigger
│   ├── BibleAPIService.swift            # bible-api.com async wrapper (actor)
│   ├── StreakManager.swift              # Streak + XP tracker (@Observable)
│   ├── NotificationService.swift        # UNUserNotificationCenter wrapper
│   ├── VerseRecommenderService.swift    # Foundation Models + FeelingMap fallback
│   └── PreviewContainer.swift           # Seeded in-memory SwiftData for previews
└── Theme/
    ├── AnchoredColors.swift             # Parchment / navy / amber palette
    ├── AnchoredTypography.swift         # SF Pro text styles + scripture serif
    └── ViewModifiers.swift              # cardSurface / amberCard / screenPadding
```

---

## Setup

### One-time

```bash
brew install xcodegen
```

### Generate and run

```bash
cd Anchored        # the folder containing project.yml
xcodegen generate  # produces Anchored.xcodeproj
open Anchored.xcodeproj
# ⌘R in Xcode
```

Re-run `xcodegen generate` any time you add or rename Swift files — it re-syncs the project structure from disk. Your source code is never touched; only the `.xcodeproj` is regenerated.

### Minimum iOS

**iOS 17.0.** The PRD asked for iOS 16 but this project uses `@Observable` (iOS 17+) in `StreakManager` and leans on SwiftData improvements that landed in 17. Bumping to 16 would require rewriting `StreakManager` around `ObservableObject` and is not a small change.

---

## The content pipeline

The 35 topics / 176 lessons / 529 questions come from three Base44 JavaScript files. A Python generator parses them and emits one Swift file.

```
layer2/source-js/*.js  →  layer2/scripts/generate_curriculum.py
                           ↓
                           Anchored/Content/GeneratedData/TopicsCatalog+Generated.swift
```

To regenerate after content edits:

```bash
cd layer2
python3 scripts/generate_curriculum.py
```

Expected output:

```
Parsed 35 topics
Parsed 176 lessons
Parsed 529 questions
529 unique question prompts (0 duplicates)
35 unique gradient combinations
```

### Adding a new Tailwind gradient

If you add a new `from-color-N to-color-M` combination in the source JS, the generator fails fast with `Missing Tailwind hex for X`. Two places to update:

1. `TAILWIND_HEX` dict in `layer2/scripts/generate_curriculum.py` (add the hex for each new color shade).
2. `TopicGradient` enum in `Anchored/Content/TopicCatalog.swift` (add a new `case` and the `hexStops` entry).

Then re-run the generator.

---

## Architecture notes

### MVVM and observability

The PRD specifies MVVM. In practice SwiftUI collapses the "V" and "VM" where they're tiny, so not every screen has a dedicated view model file. Shared state lives in:

- **`AuthManager`** (`ObservableObject`, injected via `.environmentObject`). Owns the sign-in state.
- **`PremiumManager`** (`ObservableObject`, injected via `.environmentObject`). Owns the IAP entitlement flag and the paywall-presenting binding.
- **`StreakManager`** (`@Observable`, constructed per-view in `.task`). Owns the streak + XP state; views read mirrored stored properties directly.

### Why `AuthManager`/`PremiumManager` are `ObservableObject` and `StreakManager` is `@Observable`

`AuthManager` and `PremiumManager` were built on iOS 16's `ObservableObject` protocol because they inject cleanly via `@EnvironmentObject`, which predates `@Observable`. `StreakManager` is `@Observable` because it's constructed lazily with a `ModelContext` dependency — it can't be a top-level environment object since the model context isn't available outside a `View`.

A later pass could unify both on `@Observable` + `@Environment(StreakManager.self)`, but the mixed style is intentionally pragmatic.

### SwiftData `ModelContainer`

Defined once in `AnchoredApp`. Production uses the on-disk store; if the disk store fails to open (rare — disk full, corrupt schema) we fall back to in-memory so the app still launches rather than hard-crashing. SwiftUI previews use a separate in-memory `PreviewContainer.shared` pre-seeded with sample data so previews aren't empty first-launch screens.

Schema:

- `LessonProgress` — one row per completed lesson
- `UserStreak` — singleton, current/longest streak + total XP + last check-in
- `BibleNote` — verse-anchored user notes
- `Prayer` — prayer journal entries
- `SavedVerse` — favorited verses
- `UserSettings` — translation, font size, notification prefs

---

## Integration seams between Layer 1 and Layer 2

Two mismatches had to be reconciled when merging the layers — both documented here in case you reshuffle files later.

### 1. `UserStreak` field names

Layer 1's original `UserStreak` had `totalXp`, `lastActivityDate`, plus cached `totalLessonsCompleted` and `level` fields. Layer 2's `StreakManager` reads/writes `totalXP` (capital P) and `lastCheckInDate`, and computes level from XP rather than storing it.

The merge resolved this by rewriting `UserStreak` to match `StreakManager`:

```swift
@Model
final class UserStreak {
    var currentStreak: Int
    var longestStreak: Int
    var totalXP: Int               // ← capital P
    var lastCheckInDate: Date?     // ← not "lastActivityDate"
    var userId: String?
}
```

If you ever reintroduce the dropped fields (e.g. to cache total lesson count on disk for a dashboard), add them to `UserStreak` but *don't* change the ones `StreakManager` touches.

### 2. `TopicCatalog.swift` duplication

Layer 1 shipped a stub `TopicCatalog.swift` with a single hardcoded topic. Layer 2 ships its own `TopicCatalog.swift` (richer types) + `TopicsCatalog+Generated.swift` (the 35 real topics).

The merge resolved this by **deleting Layer 1's** `TopicCatalog.swift` + `TopicsCatalog+Data.swift` and keeping Layer 2's versions. The Layer 1 stub's type shape (`accentHex: String`, `QuizQuestion.question`) was incompatible with the Layer 2 generator, so there's no path that keeps both.

---

## Design system quick reference

Palette (from `AnchoredColors`):

- `.parchment` — cream background (`#F9F5EF`), warm near-black in dark mode
- `.navy` — primary text (`#1B2A4A`)
- `.amber` — accents and CTAs (`#C9963A`)
- `.amberSoft` — tinted background for verse cards
- `.streak` — flame orange for streak badges
- `.success` / `.error` — state colors

Text styles (via `.anchoredStyle(.foo)`):

- `.h1` 28pt bold, `.h2` 20pt semibold, `.h3` 17pt semibold
- `.body` 16pt, `.bodyMd` 16pt medium, `.caption` 13pt
- `.label` 11pt semibold uppercase tracked
- `.scripture` 18pt italic serif with extra line spacing
- `.reference` 14pt semibold
- `.xpDigit` 32pt bold rounded

Surfaces (view modifiers):

- `.cardSurface()` — white card with hairline border
- `.amberCard()` — amber-tinted featured card
- `.screenPadding()` — 20pt horizontal screen padding

---

## Notifications philosophy

We never prompt for notification permission at launch. Permission is requested **only** when the user toggles the daily reminder on in Profile. If previously denied, the Profile settings shows a deep-link button that opens iOS Settings → Anchored → Notifications.

This matches Anthropic's broader "don't ambush the user" philosophy for permission dialogs and keeps onboarding quiet.

---

## What's stubbed

A few surfaces compile and look right but aren't wired to final implementations yet. They're marked with `TODO(services-pass)` comments where relevant.

- **Sign in with Apple.** `OnboardingView` calls `AuthManager.completeSignIn` with a hardcoded dev user. Swap the button for `SignInWithAppleButton` and pass the real credential through — `AuthManager.completeSignIn(userId:displayName:)` is already the right shape.
- **StoreKit 2 products.** `PremiumManager.isPremium` is always false outside of `debugUnlock()`. Real product fetching + entitlement check lands in the IAP pass; views already use `presentPaywall()` correctly so no view changes needed.
- **Topic detail / Lesson flow / Quiz.** `HomeView` and `TopicsView` both navigate to a `PlaceholderView` when a topic is tapped. The real `TopicDetailView` + `LessonView` + `QuizQuestionView` are the next build pass.
- **Verse Recommender UI.** `VerseRecommenderService` is fully implemented (Foundation Models + FeelingMap fallback). The UI that calls it is a later pass.
- **Achievements detail.** `ProfileView` renders the badge grid with correct unlocked/locked state, but tapping a badge doesn't navigate to a detail sheet yet.

---

## Running the previews

Every view has a `#Preview` macro. They all use `PreviewContainer.shared` (in-memory SwiftData with sample data) plus `.preview` / `.previewPremium` variants of the environment managers, so previews are always populated:

- Home shows a 4-day streak, 615 XP, and one Continue card.
- Topics shows Creation at 3/4 lessons complete; the other 34 topics locked (or unlocked in the "Premium" variant).
- Journal → Notes has one sample note; Prayers has one active prayer; Verses has one saved verse.
- Profile shows 3 of 8 achievements unlocked (First Steps, Faithful for 3-day streak, and one more based on seeded XP).

Tap "Resume" in the Xcode preview canvas if the first render is blank — SwiftData containers occasionally need a second to initialize.

---

## App Store preparation

When you're ready to submit:

1. Fill in `DEVELOPMENT_TEAM` in `project.yml` with your Apple Developer Team ID, then `xcodegen generate` again.
2. Set `PRODUCT_BUNDLE_IDENTIFIER` to your real bundle ID (currently `com.anchored.app`).
3. Add your `AppIcon.appiconset` and `AccentColor` asset catalog entries (the `project.yml` references these names already).
4. Flip `SWIFT_STRICT_CONCURRENCY` from `minimal` to `complete` and address any warnings.
5. Replace the dev-stub sign-in with real Sign in with Apple (see above).
6. Create your StoreKit products in App Store Connect and wire them up in `PremiumManager`.

The project is configured for both iPhone and iPad (`TARGETED_DEVICE_FAMILY: "1,2"`) and portrait-only on iPhone.
