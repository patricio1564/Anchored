//
//  AnchoredTypography.swift
//  Anchored
//
//  Typography scale. SF Pro (system default) everywhere; scripture text
//  is slightly larger and italic per the PRD. Use these as view modifiers:
//
//      Text("Welcome back").anchoredStyle(.h1)
//      Text("For God so loved...").anchoredStyle(.scripture)
//

import SwiftUI

enum AnchoredTextStyle {
    case h1       // 28pt bold — page titles
    case h2       // 20pt semibold — section headers
    case h3       // 17pt semibold — card titles
    case body     // 16pt regular
    case bodyMd   // 16pt medium
    case caption  // 13pt regular — metadata
    case label    // 11pt semibold uppercase — "VERSE OF THE DAY" style
    case scripture // 18pt italic — scripture text, slightly larger per PRD
    case reference // 14pt semibold — "— John 3:16"
    case xpDigit  // 32pt bold rounded — big stat numbers

    var font: Font {
        switch self {
        case .h1:        return .system(size: 28, weight: .bold, design: .default)
        case .h2:        return .system(size: 20, weight: .semibold, design: .default)
        case .h3:        return .system(size: 17, weight: .semibold, design: .default)
        case .body:      return .system(size: 16, weight: .regular, design: .default)
        case .bodyMd:    return .system(size: 16, weight: .medium, design: .default)
        case .caption:   return .system(size: 13, weight: .regular, design: .default)
        case .label:     return .system(size: 11, weight: .semibold, design: .default)
        case .scripture: return .system(size: 18, weight: .regular, design: .serif).italic()
        case .reference: return .system(size: 14, weight: .semibold, design: .default)
        case .xpDigit:   return .system(size: 32, weight: .bold, design: .rounded)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .scripture: return 6
        case .body, .bodyMd: return 3
        default: return 2
        }
    }

    var tracking: CGFloat {
        switch self {
        case .label: return 1.2
        default:     return 0
        }
    }

    var textCase: Text.Case? {
        switch self {
        case .label: return .uppercase
        default:     return nil
        }
    }
}

// MARK: - View Modifier

struct AnchoredStyleModifier: ViewModifier {
    let style: AnchoredTextStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .tracking(style.tracking)
            .textCase(style.textCase)
    }
}

extension View {
    /// Apply an Anchored typography style.
    func anchoredStyle(_ style: AnchoredTextStyle) -> some View {
        modifier(AnchoredStyleModifier(style: style))
    }
}
