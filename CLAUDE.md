# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

**Prerequisites (one-time):**
```bash
brew install xcodegen
```

**Generate project and open:**
```bash
cd Anchored        # the folder containing project.yml
xcodegen generate  # produces Anchored.xcodeproj
open Anchored.xcodeproj
# ⌘R in Xcode to build and run
```

Re-run `xcodegen generate` any time you add, rename, or delete Swift files — it re-syncs `.xcodeproj` from disk without touching source code.

**Regenerate curriculum content after editing source JS:**
```bash
cd layer2
python3 scripts/generate_curriculum.py
# Expected: 35 topics, 176 lessons, 529 questions, 0 duplicates
```

## Architecture

**iOS 17+ minimum** — required for `@Observable` (used in `StreakManager`) and SwiftData improvements. Bumping to iOS 16 would require rewriting `StreakManager` around `ObservableObject`.

**Project layout:**
```
Anchored/
├── App/          # Entry point (AnchoredApp), RootView, MainTabView (5 tabs)
├── Content/      # Static curriculum + curated content
│   └── GeneratedData/   # TopicsCatalog+Generated.swift — do not edit by hand
├── Features/     # One folder per tab screen
├── Models/       # SwiftData @Model types
├── Services/     # Managers, API wrappers, preview helpers
└── Theme/        # Colors, typography, view modifiers
```

**Content pipeline:**
`layer2/source-js/*.js` → `layer2/scripts/generate_curriculum.py` → `Anchored/Content/GeneratedData/TopicsCatalog+Generated.swift`

## State Management

Three shared state objects, two patterns:

- **`AuthManager`** and **`PremiumManager`** — `ObservableObject`, injected via `.environmentObject` at the root.
- **`StreakManager`** — `@Observable`, constructed per-view in `.task` because it requires a `ModelContext` (unavailable at the environment-injection point). Views read **mirrored stored properties** on the manager directly — this is intentional. `@Observable` only tracks reads/writes on the manager itself, not on a nested SwiftData model it owns, so `StreakManager` mirrors `UserStreak` fields onto its own stored properties to ensure UI updates fire.

## SwiftData

`ModelContainer` is defined once in `AnchoredApp`. Falls back to in-memory if the on-disk store fails (never crashes on launch). Previews use `PreviewContainer.shared` — a seeded in-memory container; every view has a `#Preview` macro using it.

**Schema:** `UserStreak` (singleton), `LessonProgress`, `BibleNote`, `Prayer`, `SavedVerse`, `UserSettings`.

**Field names to know:** `UserStreak` uses `totalXP` (capital P) and `lastCheckInDate` — not `totalXp`/`lastActivityDate`. If you add fields, don't rename the ones `StreakManager` touches.

## Design System

Apply via modifiers, not hardcoded values:
- **Colors:** `.parchment`, `.navy`, `.amber`, `.amberSoft`, `.streak` (from `AnchoredColors`)
- **Typography:** `.anchoredStyle(.h1)` through `.anchoredStyle(.xpDigit)` (from `AnchoredTypography`)
- **Surfaces:** `.cardSurface()`, `.amberCard()`, `.screenPadding()` (from `ViewModifiers`)

## What's Stubbed

Marked `TODO(services-pass)` in code:
- **Sign in with Apple** — `OnboardingView` calls `AuthManager.completeSignIn` with a hardcoded dev user
- **StoreKit 2** — `PremiumManager.isPremium` is always `false`; views already use `presentPaywall()` correctly
- **Topic detail / Lesson / Quiz flow** — `TopicsView` and `HomeView` navigate to `PlaceholderView`; `TopicDetailView`, `LessonView`, `QuizQuestionView` are next pass
- **Verse Recommender UI** — `VerseRecommenderService` is fully implemented (Foundation Models → FeelingMap fallback); UI integration is a later pass

## Key Services

- **`BibleAPIService`** — Actor-isolated, wraps bible-api.com. 5 translations: WEB (default/free), KJV, ASV, BBE, Darby (premium). In-memory cache keyed by reference+translation.
- **`VerseRecommenderService`** — Foundation Models (iOS 26+) with `FeelingMap` fallback. Always returns a result; never surfaces errors to the user.
- **`StreakManager`** — `checkIn(on:)` is idempotent (safe to call in every `.task`). Level titles: Seeker → Disciple → Scholar → Teacher → Elder → Shepherd (100 XP each).

## Adding a New Tailwind Gradient

If source JS uses a new `from-color-N to-color-M` combination, the generator will fail with `Missing Tailwind hex for X`. Fix in two places:
1. Add the hex to `TAILWIND_HEX` dict in `layer2/scripts/generate_curriculum.py`
2. Add a `case` to `TopicGradient` enum in `Anchored/Content/TopicCatalog.swift`

Then re-run the generator.

## App Store Prep Checklist

1. Set `DEVELOPMENT_TEAM` in `project.yml` → `xcodegen generate`
2. Update `PRODUCT_BUNDLE_IDENTIFIER` (currently `com.anchored.app`)
3. Add `AppIcon.appiconset` and `AccentColor` asset catalog entries
4. Flip `SWIFT_STRICT_CONCURRENCY` from `minimal` to `complete` and fix warnings
5. Wire real Sign in with Apple credential through `AuthManager.completeSignIn(userId:displayName:)`
6. Create StoreKit products in App Store Connect and implement `PremiumManager`
