// ────────────────────────────────────────────────────────────────────────────
// TopicCatalog.swift
//
// Hand-written companion to TopicsCatalog+Generated.swift. Declares the
// Swift types (Topic, Lesson, QuizQuestion, TopicGradient) and the
// TopicsCatalog namespace with lookup helpers. The actual data array
// lives in the generated file so we can re-emit it without touching
// anything in this file.
//
// If you update the source JS and re-run the generator, you only need
// to touch this file if a NEW gradient combination appears.
// ────────────────────────────────────────────────────────────────────────────

import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Types
// ─────────────────────────────────────────────────────────────────────────────

/// A top-level curriculum unit. Example: "Creation & Genesis".
struct Topic: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    /// Emoji. Kept as a String so the seed data reads naturally.
    let icon: String
    let gradient: TopicGradient
    let lessons: [Lesson]

    /// Premium gating: only the first topic (creation) is free in the MVP.
    var isFree: Bool { id == "creation" }
}

/// One lesson within a topic. Contains teaching prose, a key verse, and a
/// short quiz at the end.
struct Lesson: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    /// Scripture reference the lesson is anchored in. Free-text, e.g. "Genesis 1:1-5".
    let scripture: String
    /// Long-form teaching text shown on the reading screen.
    let teaching: String
    /// The headline verse. Displayed as a pull-quote and stored as a review card.
    let keyVerse: String
    let questions: [QuizQuestion]
}

/// A single multiple-choice question with explanatory feedback.
struct QuizQuestion: Hashable, Sendable {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    /// Shown after the user answers — explains the reasoning and the scripture.
    let explanation: String
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Gradient palette
// ─────────────────────────────────────────────────────────────────────────────

/// Every distinct Tailwind gradient that appears in the Base44 curriculum.
///
/// The generator validates that all 35 gradients used in the seed data
/// map to a case here. If the source adds a new combo, add a case + hex
/// stops and the generator will pick it up on the next run.
enum TopicGradient: String, CaseIterable, Hashable, Sendable {
    case emerald500ToTeal600
    case amber500ToOrange600
    case red500ToRose600
    case stone500ToSlate600
    case indigo500ToBlue600
    case pink500ToRose500
    case violet500ToPurple600
    case cyan500ToSky600
    case sky500ToBlue600
    case yellow500ToAmber600
    case orange500ToRed500
    case teal500ToCyan600
    case rose500ToPink600
    case blue400ToSky500
    case purple400ToViolet600
    case pink400ToRose500
    case green500ToEmerald600
    case red500ToOrange600
    case indigo400ToBlue500
    case yellow400ToAmber500
    case slate500ToGray600
    case violet500ToIndigo600
    case teal500ToEmerald600
    case orange400ToRed500
    case cyan400ToTeal500
    case fuchsia500ToPurple600
    case stone500ToAmber700
    case blue500ToIndigo600
    case amber400ToYellow500
    case slate400ToBlue600
    case red400ToRose600
    case green400ToTeal500
    case yellow500ToOrange500
    case violet400ToBlue500
    case emerald400ToGreen600

    /// Two hex strings: (start, end). Consumed by `linearGradient`.
    var hexStops: (start: String, end: String) {
        switch self {
        case .emerald500ToTeal600:   return ("#10B981", "#0D9488")
        case .amber500ToOrange600:   return ("#F59E0B", "#EA580C")
        case .red500ToRose600:       return ("#EF4444", "#E11D48")
        case .stone500ToSlate600:    return ("#78716C", "#475569")
        case .indigo500ToBlue600:    return ("#6366F1", "#2563EB")
        case .pink500ToRose500:      return ("#EC4899", "#F43F5E")
        case .violet500ToPurple600:  return ("#8B5CF6", "#9333EA")
        case .cyan500ToSky600:       return ("#06B6D4", "#0284C7")
        case .sky500ToBlue600:       return ("#0EA5E9", "#2563EB")
        case .yellow500ToAmber600:   return ("#EAB308", "#D97706")
        case .orange500ToRed500:     return ("#F97316", "#EF4444")
        case .teal500ToCyan600:      return ("#14B8A6", "#0891B2")
        case .rose500ToPink600:      return ("#F43F5E", "#DB2777")
        case .blue400ToSky500:       return ("#60A5FA", "#0EA5E9")
        case .purple400ToViolet600:  return ("#C084FC", "#7C3AED")
        case .pink400ToRose500:      return ("#F472B6", "#F43F5E")
        case .green500ToEmerald600:  return ("#22C55E", "#059669")
        case .red500ToOrange600:     return ("#EF4444", "#EA580C")
        case .indigo400ToBlue500:    return ("#818CF8", "#3B82F6")
        case .yellow400ToAmber500:   return ("#FACC15", "#F59E0B")
        case .slate500ToGray600:     return ("#64748B", "#4B5563")
        case .violet500ToIndigo600:  return ("#8B5CF6", "#4F46E5")
        case .teal500ToEmerald600:   return ("#14B8A6", "#059669")
        case .orange400ToRed500:     return ("#FB923C", "#EF4444")
        case .cyan400ToTeal500:      return ("#22D3EE", "#14B8A6")
        case .fuchsia500ToPurple600: return ("#D946EF", "#9333EA")
        case .stone500ToAmber700:    return ("#78716C", "#B45309")
        case .blue500ToIndigo600:    return ("#3B82F6", "#4F46E5")
        case .amber400ToYellow500:   return ("#FBBF24", "#EAB308")
        case .slate400ToBlue600:     return ("#94A3B8", "#2563EB")
        case .red400ToRose600:       return ("#F87171", "#E11D48")
        case .green400ToTeal500:     return ("#4ADE80", "#14B8A6")
        case .yellow500ToOrange500:  return ("#EAB308", "#F97316")
        case .violet400ToBlue500:    return ("#A78BFA", "#3B82F6")
        case .emerald400ToGreen600:  return ("#34D399", "#16A34A")
        }
    }

    /// Ready-to-use SwiftUI gradient in top-leading → bottom-trailing direction.
    var linearGradient: LinearGradient {
        let stops = hexStops
        return LinearGradient(
            colors: [Color(hex: stops.start), Color(hex: stops.end)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Color(hex:)
// ─────────────────────────────────────────────────────────────────────────────

extension Color {
    /// Parse a `#RRGGBB` or `#AARRGGBB` hex string into a SwiftUI Color.
    /// Unknown input falls back to `.gray` rather than crashing, which keeps
    /// preview and release builds resilient to any future palette typos.
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else {
            self = .gray
            return
        }

        let length = hex.replacingOccurrences(of: "#", with: "").count
        let r, g, b, a: Double
        switch length {
        case 6:
            a = 1.0
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
        case 8:
            a = Double((value >> 24) & 0xFF) / 255.0
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
        default:
            self = .gray
            return
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - TopicsCatalog namespace
// ─────────────────────────────────────────────────────────────────────────────

/// Static access point for all curriculum data. The `generatedAll` array
/// itself lives in `TopicsCatalog+Generated.swift`.
enum TopicsCatalog {

    /// All topics in the order the curriculum was authored (Base → Extra → Extra2).
    static var all: [Topic] { generatedAll }

    /// Free topics (MVP gating: only "creation" is free).
    static var free: [Topic] { all.filter(\.isFree) }

    /// Premium-only topics.
    static var premium: [Topic] { all.filter { !$0.isFree } }

    /// O(n) lookup, but n=35 so it's not worth caching.
    static func topic(withID id: String) -> Topic? {
        all.first { $0.id == id }
    }

    /// Returns both the enclosing topic and the lesson. Useful for deep links.
    static func lesson(withID lessonID: String) -> (topic: Topic, lesson: Lesson)? {
        for topic in all {
            if let lesson = topic.lessons.first(where: { $0.id == lessonID }) {
                return (topic, lesson)
            }
        }
        return nil
    }

    /// Total question count across the whole curriculum.
    /// Used in the profile's "questions answered of total" stat.
    static var totalQuestionCount: Int {
        all.reduce(0) { topicSum, topic in
            topicSum + topic.lessons.reduce(0) { $0 + $1.questions.count }
        }
    }

    /// Total lesson count across the whole curriculum.
    static var totalLessonCount: Int {
        all.reduce(0) { $0 + $1.lessons.count }
    }
}
