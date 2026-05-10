import SwiftUI
import SwiftData

struct MainTabView: View {

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @State private var streakManager: StreakManager?
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home, learn, bible, journal, profile

        var label: String {
            switch self {
            case .home:    return "Home"
            case .learn:   return "Learn"
            case .bible:   return "Bible"
            case .journal: return "Journal"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home:    return "house.fill"
            case .learn:   return "graduationcap.fill"
            case .bible:   return "book.fill"
            case .journal: return "square.and.pencil"
            case .profile: return "person.crop.circle.fill"
            }
        }
    }

    var body: some View {
        Group {
            if let streakManager {
                content.environment(streakManager)
            } else {
                content.task {
                    let manager = StreakManager(
                        modelContext: modelContext,
                        userId: authManager.currentUserId ?? "anonymous"
                    )
                    self.streakManager = manager
                }
            }
        }
    }

    static let tabBarHeight: CGFloat = 96

    private var content: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack { HomeView() }
                case .learn:
                    NavigationStack { TopicsView() }
                case .bible:
                    NavigationStack { BibleView() }
                case .journal:
                    NavigationStack { JournalView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }

            dawnTabBar
        }
    }

    // MARK: - Dawn Tab Bar

    private var dawnTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let isActive = tab == selectedTab
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    isActive
                                    ? AnyShapeStyle(AnchoredColors.gradientPrimary)
                                    : AnyShapeStyle(Color.clear)
                                )
                                .frame(width: 38, height: 30)
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(isActive ? .white : AnchoredColors.inkSoft)
                        }
                        Text(tab.label)
                            .font(.custom("Outfit", size: 10).weight(.semibold))
                            .foregroundStyle(isActive ? AnchoredColors.coral : AnchoredColors.inkSoft)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AnchoredColors.line, lineWidth: 1)
                )
                .shadow(color: AnchoredColors.ink.opacity(0.2), radius: 15, x: 0, y: -6)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 18)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}
