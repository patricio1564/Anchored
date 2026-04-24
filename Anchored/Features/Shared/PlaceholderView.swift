//
//  PlaceholderView.swift
//  Anchored
//
//  Shared placeholder used by every feature stub until real implementations
//  land. Each feature screen is a thin wrapper around this so the tab bar
//  and navigation work end-to-end from day one.
//
//  STATUS: ALL STUBS — feature views get their real implementations in the
//  next build pass.
//

import SwiftUI

struct PlaceholderView: View {
    let title: String
    let systemIcon: String
    let description: String

    var body: some View {
        ZStack {
            AnchoredColors.parchment.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: systemIcon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AnchoredColors.amber)

                Text(title)
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.navy)

                Text(description)
                    .anchoredStyle(.body)
                    .foregroundStyle(AnchoredColors.muted)
                    .multilineTextAlignment(.center)
                    .screenPadding()

                Text("Coming in next build pass")
                    .anchoredStyle(.label)
                    .foregroundStyle(AnchoredColors.amber)
                    .padding(.top, 8)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PlaceholderView(
            title: "Home",
            systemIcon: "house.fill",
            description: "Daily verse, streak, and quick-access cards will live here."
        )
    }
}
