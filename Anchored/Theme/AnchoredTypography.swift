import SwiftUI

enum AnchoredTextStyle {
    case display      // 38 serif/400  line 1.05  tracking -.02em
    case titleXL      // 32 serif/400  1.05       -.02em
    case title        // 28 serif/400  1.10       -.02em
    case titleCard    // 22 serif/500  1.20
    case subtitleL    // 18 serif/500  1.30
    case bodyL        // 17 serif/400
    case body         // 14.5 sans/500
    case bodyS        // 13 sans/500
    case caption      // 12 sans/500  color ink-soft
    case caps         // 11 sans/600  tracking .14em UPPER
    case scripture    // 19 serif italic/400  line 1.4
    case statNumber   // 24 serif/500  tabular-nums
    case priceNumber  // 30 serif/500

    // Legacy aliases for existing code
    case h1
    case h2
    case h3
    case bodyMd
    case label
    case reference
    case xpDigit

    var font: Font {
        switch self {
        case .display:     return .custom("Newsreader", size: 38).weight(.regular)
        case .titleXL:     return .custom("Newsreader", size: 32).weight(.regular)
        case .title:       return .custom("Newsreader", size: 28).weight(.regular)
        case .titleCard:   return .custom("Newsreader", size: 22).weight(.medium)
        case .subtitleL:   return .custom("Newsreader", size: 18).weight(.medium)
        case .bodyL:       return .custom("Newsreader", size: 17).weight(.regular)
        case .body:        return .custom("Outfit", size: 14.5).weight(.medium)
        case .bodyS:       return .custom("Outfit", size: 13).weight(.medium)
        case .caption:     return .custom("Outfit", size: 12).weight(.medium)
        case .caps:        return .custom("Outfit", size: 11).weight(.semibold)
        case .scripture:   return .custom("Newsreader", size: 19).weight(.regular).italic()
        case .statNumber:  return .custom("Newsreader", size: 24).weight(.medium)
        case .priceNumber: return .custom("Newsreader", size: 30).weight(.medium)

        case .h1:          return .custom("Newsreader", size: 28).weight(.regular)
        case .h2:          return .custom("Newsreader", size: 22).weight(.medium)
        case .h3:          return .custom("Newsreader", size: 18).weight(.medium)
        case .bodyMd:      return .custom("Outfit", size: 14.5).weight(.semibold)
        case .label:       return .custom("Outfit", size: 11).weight(.semibold)
        case .reference:   return .custom("Outfit", size: 14).weight(.semibold)
        case .xpDigit:     return .custom("Newsreader", size: 32).weight(.medium)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .display, .titleXL:   return 0
        case .title:               return 2
        case .titleCard:           return 4
        case .subtitleL:           return 5
        case .bodyL:               return 4
        case .body, .bodyS:        return 3
        case .scripture:           return 7
        case .caption:             return 2
        default:                   return 2
        }
    }

    var tracking: CGFloat {
        switch self {
        case .display, .titleXL, .title, .h1:
            return -0.76
        case .caps, .label:
            return 1.54
        default:
            return 0
        }
    }

    var textCase: Text.Case? {
        switch self {
        case .caps, .label: return .uppercase
        default:            return nil
        }
    }
}

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
    func anchoredStyle(_ style: AnchoredTextStyle) -> some View {
        modifier(AnchoredStyleModifier(style: style))
    }
}
