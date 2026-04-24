//
//  ViewModifiers.swift
//  Anchored
//
//  Reusable view modifiers for cards, surfaces, and common treatments.
//

import SwiftUI

// MARK: - Card Surface

/// Standard card container — white surface, rounded, hairline border.
struct CardSurfaceModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AnchoredColors.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AnchoredColors.border, lineWidth: 1)
            )
    }
}

/// Amber-tinted card — used for the daily verse and other featured content.
struct AmberCardModifier: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AnchoredColors.amberSoft)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AnchoredColors.amber.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func cardSurface(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        modifier(CardSurfaceModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func amberCard(padding: CGFloat = 20, cornerRadius: CGFloat = 20) -> some View {
        modifier(AmberCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Screen Padding

extension View {
    /// Consistent horizontal screen padding (20pt each side).
    func screenPadding() -> some View {
        padding(.horizontal, 20)
    }
}
