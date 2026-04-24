// ────────────────────────────────────────────────────────────────────────────
// DailyVerses.swift
//
// Curated 28-verse pool cycled by day-of-year. Verbatim pool from the
// Base44 source (bibleContent.js → DAILY_VERSES).
//
// Why curated over API random?
//   1. Deterministic — "today's verse" is the same no matter when the app
//      is opened, even if offline, even if the API is down.
//   2. Pastorally selected — these are foundational passages chosen for
//      encouragement, not arbitrary chapter-openers.
//   3. Translation switching still flows through BibleAPIService: the
//      reference is stable, only the text is re-fetched when the user
//      picks a paid translation.
// ────────────────────────────────────────────────────────────────────────────

import Foundation

/// Immutable daily-verse record. `text` is the default WEB-friendly
/// rendering. If the user switches translation, we re-fetch just the
/// text via `BibleAPIService` keyed on `reference`.
struct DailyVerse: Hashable, Sendable {
    let text: String
    let reference: String
}

enum DailyVerses {

    /// The curated pool. Order matters — day-of-year indexes into this array,
    /// so changing the order changes which verse people see on a given day.
    /// Adding new verses at the end is safe; reordering is not.
    static let pool: [DailyVerse] = [
        DailyVerse(
            text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
            reference: "Jeremiah 29:11"
        ),
        DailyVerse(
            text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
            reference: "Proverbs 3:5-6"
        ),
        DailyVerse(
            text: "I can do all this through him who gives me strength.",
            reference: "Philippians 4:13"
        ),
        DailyVerse(
            text: "The Lord is my light and my salvation—whom shall I fear? The Lord is the stronghold of my life—of whom shall I be afraid?",
            reference: "Psalm 27:1"
        ),
        DailyVerse(
            text: "Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.",
            reference: "Joshua 1:9"
        ),
        DailyVerse(
            text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.",
            reference: "Isaiah 40:31"
        ),
        DailyVerse(
            text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
            reference: "Romans 8:28"
        ),
        DailyVerse(
            text: "The Lord is close to the brokenhearted and saves those who are crushed in spirit.",
            reference: "Psalm 34:18"
        ),
        DailyVerse(
            text: "Come to me, all you who are weary and burdened, and I will give you rest.",
            reference: "Matthew 11:28"
        ),
        DailyVerse(
            text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.",
            reference: "Philippians 4:6"
        ),
        DailyVerse(
            text: "He has shown you, O mortal, what is good. And what does the Lord require of you? To act justly and to love mercy and to walk humbly with your God.",
            reference: "Micah 6:8"
        ),
        DailyVerse(
            text: "Your word is a lamp for my feet, a light on my path.",
            reference: "Psalm 119:105"
        ),
        DailyVerse(
            text: "The name of the Lord is a fortified tower; the righteous run to it and are safe.",
            reference: "Proverbs 18:10"
        ),
        DailyVerse(
            text: "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness and self-control.",
            reference: "Galatians 5:22-23"
        ),
        DailyVerse(
            text: "For we are God's handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.",
            reference: "Ephesians 2:10"
        ),
        DailyVerse(
            text: "The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.",
            reference: "Zephaniah 3:17"
        ),
        DailyVerse(
            text: "My grace is sufficient for you, for my power is made perfect in weakness.",
            reference: "2 Corinthians 12:9"
        ),
        DailyVerse(
            text: "For it is by grace you have been saved, through faith — and this is not from yourselves, it is the gift of God.",
            reference: "Ephesians 2:8"
        ),
        DailyVerse(
            text: "If we confess our sins, he is faithful and just and will forgive us our sins and purify us from all unrighteousness.",
            reference: "1 John 1:9"
        ),
        DailyVerse(
            text: "Cast all your anxiety on him because he cares for you.",
            reference: "1 Peter 5:7"
        ),
        DailyVerse(
            text: "Create in me a pure heart, O God, and renew a steadfast spirit within me.",
            reference: "Psalm 51:10"
        ),
        DailyVerse(
            text: "I praise you because I am fearfully and wonderfully made.",
            reference: "Psalm 139:14"
        ),
        DailyVerse(
            text: "God is our refuge and strength, an ever-present help in trouble.",
            reference: "Psalm 46:1"
        ),
        DailyVerse(
            text: "Let us run with perseverance the race marked out for us, fixing our eyes on Jesus.",
            reference: "Hebrews 12:1-2"
        ),
        DailyVerse(
            text: "Where you go I will go, and where you stay I will stay. Your people will be my people and your God my God.",
            reference: "Ruth 1:16"
        ),
        DailyVerse(
            text: "He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain.",
            reference: "Revelation 21:4"
        ),
        DailyVerse(
            text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
            reference: "John 3:16"
        ),
        DailyVerse(
            text: "I am the way and the truth and the life. No one comes to the Father except through me.",
            reference: "John 14:6"
        )
    ]

    /// The verse to show today. Deterministic from the device's calendar date —
    /// opens at midnight local time advances to the next verse.
    ///
    /// Uses the user's current calendar (not UTC) so the "new verse" moment
    /// aligns with the user's wake-up, not with Greenwich.
    static func today(in calendar: Calendar = .current, now: Date = Date()) -> DailyVerse {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let index = (dayOfYear - 1) % pool.count  // ordinality is 1-based
        return pool[index]
    }

    /// Helper for tests / previews: verse for an arbitrary date.
    static func verse(for date: Date, calendar: Calendar = .current) -> DailyVerse {
        today(in: calendar, now: date)
    }
}
