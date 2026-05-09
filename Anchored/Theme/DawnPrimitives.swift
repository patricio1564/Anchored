import SwiftUI

// MARK: - BrandHeader (onboarding)

struct BrandHeader: View {
    var step: Int? = nil
    var total: Int? = nil

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(AnchoredColors.gradientPrimary)
                    .frame(width: 18, height: 18)
                Text("Anchored")
                    .font(.custom("Newsreader", size: 18).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
            }

            if let total {
                HStack(spacing: 5) {
                    ForEach(0..<total, id: \.self) { i in
                        Capsule()
                            .fill(dotColor(index: i))
                            .frame(width: i == (step ?? 0) ? 20 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: step)
                    }
                }
            }
        }
        .padding(.top, 54)
    }

    private func dotColor(index: Int) -> Color {
        let current = step ?? 0
        if index == current { return AnchoredColors.coral }
        if index < current { return AnchoredColors.coralSoft }
        return Color(red: 31/255, green: 38/255, blue: 71/255).opacity(0.12)
    }
}

// MARK: - PrimaryButton

struct DawnButton: View {
    let label: String
    var primary: Bool = true
    var icon: String? = nil
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(label)
                    .font(.custom("Outfit", size: 15.5).weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(
                Group {
                    if primary {
                        AnchoredColors.gradientPrimary
                    } else {
                        AnchoredColors.glass
                            .background(.ultraThinMaterial)
                    }
                }
            )
            .clipShape(Capsule())
            .foregroundStyle(primary ? .white : AnchoredColors.ink)
            .shadow(
                color: primary ? AnchoredColors.coral.opacity(0.4) : .clear,
                radius: 15, x: 0, y: 12
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}

// MARK: - Bottom-Anchored Button

struct DawnBottomButton: View {
    let label: String
    var primary: Bool = true
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            DawnButton(label: label, primary: primary, disabled: disabled, action: action)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
        }
    }
}

// MARK: - SelectionTile (multi-select grid)

struct SelectionTile: View {
    let label: String
    let icon: String
    let accent: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selected ? Color.white.opacity(0.2) : accent.opacity(0.13))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(selected ? .white : accent)
                }

                Text(label)
                    .font(.custom("Outfit", size: 14.5).weight(.semibold))
                    .lineHeight(multiplier: 1.25)
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .background(
                Group {
                    if selected {
                        LinearGradient(
                            colors: [accent, accent.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        AnchoredColors.glass
                            .background(.ultraThinMaterial)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                Group {
                    if !selected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(AnchoredColors.line, lineWidth: 1)
                    }
                }
            )
            .foregroundStyle(selected ? .white : AnchoredColors.ink)
            .shadow(
                color: selected ? accent.opacity(0.3) : .clear,
                radius: 12, x: 0, y: 10
            )
            .overlay(alignment: .topTrailing) {
                if selected {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - RadioRow (single-select)

struct RadioRow: View {
    let title: String
    let subtitle: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.custom("Outfit", size: 16).weight(.semibold))
                        .foregroundStyle(selected ? .white : AnchoredColors.ink)
                    Text(subtitle)
                        .font(.custom("Outfit", size: 12.5))
                        .foregroundStyle(selected ? Color.white.opacity(0.85) : AnchoredColors.inkSoft)
                }
                Spacer()
                Circle()
                    .fill(selected ? Color.white.opacity(0.3) : .clear)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .stroke(selected ? .white : AnchoredColors.inkMute, lineWidth: 1.5)
                    )
                    .overlay {
                        if selected {
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                Group {
                    if selected {
                        AnchoredColors.gradientPrimary
                    } else {
                        AnchoredColors.glass
                            .background(.ultraThinMaterial)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                Group {
                    if !selected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(AnchoredColors.line, lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: selected ? AnchoredColors.coral.opacity(0.35) : .clear,
                radius: 14, x: 0, y: 12
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DawnToggle

struct DawnToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) { isOn.toggle() }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(
                        isOn
                        ? AnyShapeStyle(AnchoredColors.gradientPrimary)
                        : AnyShapeStyle(AnchoredColors.inkMute)
                    )
                    .frame(width: 48, height: 28)

                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .padding(2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - VerseCard (devotional)

struct VerseCard: View {
    let citation: String
    let verse: String
    var reflection: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(citation)
                .font(.custom("Outfit", size: 11).weight(.semibold))
                .tracking(0.44)
                .textCase(.uppercase)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AnchoredColors.coral, in: Capsule())

            Text(verse)
                .font(.custom("Newsreader", size: 19).weight(.regular).italic())
                .lineSpacing(7)
                .foregroundStyle(AnchoredColors.ink)

            if let reflection {
                Text(reflection)
                    .font(.custom("Outfit", size: 12.5))
                    .lineSpacing(4)
                    .foregroundStyle(AnchoredColors.inkSoft)
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.9), AnchoredColors.coralSoft.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AnchoredColors.coralSoft, lineWidth: 1)
        )
    }
}

// MARK: - Helper

private extension Text {
    func lineHeight(multiplier: CGFloat) -> Text {
        self
    }
}
