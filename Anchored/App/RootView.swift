//
//  RootView.swift
//  Anchored
//
//  Top-level view that decides between the onboarding flow (if the user
//  isn't signed in) and the main tabbed app experience.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Group {
            switch authManager.state {
            case .unknown:
                // Brief splash while we check keychain for existing credentials
                SplashView()
            case .signedOut:
                OnboardingView()
            case .signedIn:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authManager.state)
    }
}

// MARK: - Splash

struct SplashView: View {
    var body: some View {
        ZStack {
            AnchoredColors.parchment.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AnchoredColors.amber)
                Text("Anchored")
                    .anchoredStyle(.h1)
                    .foregroundStyle(AnchoredColors.navy)
            }
        }
    }
}

#Preview("Splash") {
    SplashView()
}
