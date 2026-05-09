import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Group {
            switch authManager.state {
            case .unknown:
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

struct SplashView: View {
    var body: some View {
        ZStack {
            AnchoredColors.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 12) {
                Circle()
                    .fill(AnchoredColors.gradientPrimary)
                    .frame(width: 48, height: 48)
                Text("Anchored")
                    .font(.custom("Newsreader", size: 24).weight(.medium))
                    .foregroundStyle(AnchoredColors.ink)
            }
        }
    }
}

#Preview("Splash") {
    SplashView()
}
