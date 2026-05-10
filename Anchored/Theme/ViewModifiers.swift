import SwiftUI

// MARK: - Glass Card Surface

struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 22
    var strong: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(strong ? 1 : 0.45)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(strong ? AnchoredColors.glassStrong : AnchoredColors.glass)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AnchoredColors.line, lineWidth: 1)
            )
    }
}

// MARK: - Legacy Card Surface (for existing code)

struct CardSurfaceModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content.modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}

struct AmberCardModifier: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.9), AnchoredColors.coralSoft.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AnchoredColors.coralSoft, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(padding: CGFloat = 20, cornerRadius: CGFloat = 22, strong: Bool = false) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius, strong: strong))
    }

    func cardSurface(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func amberCard(padding: CGFloat = 20, cornerRadius: CGFloat = 20) -> some View {
        modifier(AmberCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Screen Padding

extension View {
    func screenPadding() -> some View {
        padding(.horizontal, 22)
    }
}

// MARK: - App Background

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AnchoredColors.backgroundGradient.ignoresSafeArea()

            ZStack {
                // Coral glow at top
                RadialGradient(
                    colors: [AnchoredColors.coralSoft.opacity(0.28), .clear],
                    center: UnitPoint(x: 0.5, y: -0.1),
                    startRadius: 0,
                    endRadius: 300
                )
                // Lilac glow at right
                RadialGradient(
                    colors: [AnchoredColors.lilac.opacity(0.12), .clear],
                    center: UnitPoint(x: 1.0, y: 0.5),
                    startRadius: 0,
                    endRadius: 250
                )
                // Blue glow at bottom-left
                RadialGradient(
                    colors: [AnchoredColors.blueSoft.opacity(0.25), .clear],
                    center: UnitPoint(x: 0.0, y: 0.9),
                    startRadius: 0,
                    endRadius: 280
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

// MARK: - Press Feedback

struct PressScaleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaleEffect(1.0)
            .animation(.easeOut(duration: 0.1), value: false)
    }
}
