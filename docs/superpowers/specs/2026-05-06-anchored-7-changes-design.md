# Anchored — 7-Change Feature Spec

**Date:** 2026-05-06
**Status:** Approved

## Overview

Seven coordinated changes to the Anchored iOS app: onboarding flow restructure with improved visuals, subscription paywall with real pricing, notification time picker, keyboard dismissal fix, prayer step with XP reward, ASV as default translation, and a light/dark mode switcher.

## 1. Onboarding Flow Restructure

### New Page Order (9 pages, 0–8)

| Page | Name | Description |
|------|------|-------------|
| 0 | Welcome | Branding + intro |
| 1 | Goals | Multi-select chips |
| 2 | Experience | Single-select rows |
| 3 | Notifications | Opt-in toggle + time picker |
| 4 | Verse Recommender | Feelings text input → verse display |
| 5 | Prayer | Generated prayer with "Amen" / "Skip" |
| 6 | Praise | Confetti + 100 XP (conditional — only if prayed) |
| 7 | Subscription | Weekly/yearly pricing + Apple disclosures |
| 8 | Sign In | Sign in with Apple |

### Changes from current flow
- Notifications moved from Profile-only to page 3 (with inline time picker)
- Paywall moved from page 3 to page 7 (after emotional high of verse → prayer → praise)
- Two new pages: Prayer (5) and Praise (6)
- Praise is conditional — only shown if user taps "Amen"; "Skip" jumps to page 7

## 2. Onboarding Visual Overhaul (Change 4)

All onboarding content cards/boxes use:
- **Background:** navy (`#1B2A4A`)
- **Headlines:** gold/amber (`#C9963A`)
- **Body text:** parchment (`#F9F5EF`)
- **SF Symbols/icons:** amber

This applies to all steps: welcome slides, goal chips, experience rows, notification card, feelings input, verse display, prayer card, praise screen, paywall cards, and sign-in.

The dark background of the onboarding screens is kept; only the card interiors change from off-white to navy.

## 3. Keyboard Dismissal (Change 5)

On the Verse Recommender page (page 4), when the user taps "Continue" / "Find verses" after typing their feeling:
- `@FocusState private var isFeelingFieldFocused: Bool` bound to the TextEditor via `.focused($isFeelingFieldFocused)`
- Set `isFeelingFieldFocused = false` in the button action before advancing
- Keyboard dismisses before the verse fade-in animation begins

## 4. Notification Time Picker (Change 3)

### Onboarding (Page 3)
- Navy card with bell SF Symbol in amber
- "Stay rooted in the Word" headline (amber)
- "Get a gentle daily reminder to read and learn" body (parchment)
- Toggle to enable notifications → triggers system permission prompt
- **If accepted:** `DatePicker` with `.datePickerStyle(.wheel)` and `displayedComponents: .hourAndMinute` slides in below toggle, defaulting to 8:00 AM
- **If declined:** "Continue" button advances immediately, no time picker
- Saves to `UserSettings.dailyReminderTime` ("HH:mm" format)
- Schedules via `NotificationService.scheduleDailyReminder(hour:minute:)`

### Notification Content
- Title: "Time to grow in the Word 📖"
- Body: "Your daily verse and lessons are waiting for you."

### Profile/Settings Addition
- When the daily reminder toggle is on, a time picker row appears below it
- Uses the same `DatePicker` with hour/minute
- Changes reschedule the notification via `NotificationService`

## 5. Subscription Paywall (Change 1)

### Layout (Page 7, top to bottom)
1. **Header:** "Unlock Anchored Premium" with sparkles icon, amber text
2. **Feature list:** 4 bullets in parchment:
   - All 35 topics & 176 lessons
   - 5 Bible translations
   - Verse Recommender
   - All future content
3. **Plan cards:** side-by-side
   - **Yearly (emphasized):** amber border, "Best Value" badge, "$29.99/year", "Save 42%" subtext
   - **Weekly:** plain navy card, "$0.99/week"
   - Uses `Product.products(for: ["AnchoredYearly", "AnchoredWeekly"])` for real prices; falls back to hardcoded if StoreKit returns empty
4. **Subscribe button:** full-width amber, purchases selected plan
5. **Apple disclosures:** small parchment text:
   - "Payment will be charged to your Apple Account at confirmation of purchase"
   - "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period"
6. **Footer links:** [Terms of Service](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) | [Privacy Policy](https://patricio1564.github.io/Anchored/privacy-policy)
7. **Restore Purchases:** text button → `PremiumManager.restorePurchases()`
8. **Skip:** "Continue with Free" text button → advances to Sign In (page 8)

### PremiumManager Changes
- Product IDs: `AnchoredWeekly` and `AnchoredYearly` (replacing `com.anchored.app.premium.monthly` and `com.anchored.app.premium.yearly`)
- `Plan` enum: `.weekly` and `.yearly` (replacing `.monthly` and `.yearly`)

## 6. Prayer Step (Change 6)

### Prayer Page (Page 5)
- Navy card with 🙏 icon
- "Let's Talk to God" headline (amber)
- **Loading state:** "Preparing a prayer for you..." with pulsing opacity animation
- **Prayer text:** 2–4 sentences, first person, conversational tone (parchment)
- **Generation strategy:**
  - Foundation Models (iOS 26+): generate fresh prayer from prompt using user's feeling + recommended verse
  - Fallback: use `RecommendedVerse.prayer` field from the curated `FeelingMap`
- Prompt: "Take a moment to pray this to the Lord" (muted parchment)
- **Two buttons:**
  - "Amen 🙏" — large amber button → advances to Praise (page 6)
  - "Skip" — subtle text button → jumps to Subscription (page 7)

### Praise Page (Page 6)
- Only reached if user tapped "Amen"
- Confetti/sparkle animation (SwiftUI Canvas overlay)
- "God heard every word." headline (amber)
- "+100 XP" with scale-up animation
- Awards via `streakManager.awardXP(100)`
- "Continue" button → advances to Subscription (page 7)

## 7. ASV Default Translation (Change 2)

- `BibleTranslation.isFree`: `.asv` returns `true`, `.web` returns `false`
- `UserSettings.preferredTranslation` default value: `"asv"` (was `"web"`)
- Existing users who stored `"web"` keep WEB; only new installs default to ASV
- All fetch call sites already read the user's saved preference — no other changes needed

## 8. Dark Mode Switcher (Change 7)

### New File: `Services/AppearanceManager.swift`
- `@Observable @MainActor` class
- Reads/writes `UserDefaults` key `"appearanceMode"` (values: `"system"`, `"light"`, `"dark"`)
- Default: `"system"`
- Computed property `colorScheme: ColorScheme?` — `nil` for system, `.light` for light, `.dark` for dark

### Root View Integration (`AnchoredApp.swift`)
- `AppearanceManager` created as `@State` on `AnchoredApp`
- `.preferredColorScheme(appearanceManager.colorScheme)` applied to `RootView()`
- Injected into environment for access by ProfileView

### Profile/Settings
- New "Appearance" section with segmented picker: System | Light | Dark
- Placed above the existing Translation picker

### Colors
- `AnchoredColors.swift` already has dark mode variants for all colors via `Color(light:dark:)` initializer — no color changes needed

## Files Changed

### New Files
- `Services/AppearanceManager.swift`

### Modified Files
- `Features/Onboarding/OnboardingView.swift` — flow restructure, visual overhaul, keyboard dismiss, notification time picker, prayer/praise steps
- `Features/Profile/ProfileView.swift` — appearance picker, reminder time picker
- `Services/PremiumManager.swift` — product IDs (`AnchoredWeekly`, `AnchoredYearly`), Plan enum (`.weekly`/`.yearly`)
- `Services/BibleAPIService.swift` — `isFree` flag (ASV=free, WEB=premium)
- `Models/UserSettings.swift` — default translation `"asv"`
- `App/AnchoredApp.swift` — AppearanceManager creation + `.preferredColorScheme()`
- `Services/NotificationService.swift` — verify scheduling supports onboarding flow (likely no changes needed, API already exists)

## Verification Checklist

1. Build succeeds with no errors
2. Onboarding flow: Welcome → Goals → Experience → Notifications → Verse → Prayer → Praise → Subscription → Sign In
3. Onboarding boxes are navy with gold headlines and parchment body text
4. Typing a feeling and pressing Continue dismisses the keyboard
5. Notification opt-in shows time picker defaulting to 8:00 AM
6. After verse, prayer appears with "Amen" and "Skip" buttons
7. Tapping "Amen" shows confetti + 100 XP celebration
8. Tapping "Skip" bypasses prayer without awarding XP
9. Paywall shows $0.99/week and $29.99/year with "Save 42%" on yearly
10. Apple subscription disclosures, ToS link, Privacy link, and Restore Purchases are present
11. Bible reader defaults to ASV for new installs
12. ASV is free; WEB/KJV/BBE/Darby are premium
13. Profile/Settings has Appearance section with System/Light/Dark
14. Switching appearance mode works immediately
15. Profile/Settings shows reminder time picker when toggle is on
16. Dark mode colors are warm and readable
17. All `#Preview` macros render without crashes
