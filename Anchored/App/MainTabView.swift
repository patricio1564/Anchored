//
//  MainTabView.swift
//  Anchored
//
//  The five primary tabs: Home, Learn, Bible, Journal, Profile. Each tab
//  hosts its own NavigationStack so deep navigation stays scoped to the
//  tab it started from.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @State private var streakManager: StreakManager?

    var body: some View {
        Group {
            if let streakManager {
                tabContent.environment(streakManager)
            } else {
                tabContent.task {
                    let manager = StreakManager(
                        modelContext: modelContext,
                        userId: authManager.currentUserId ?? "anonymous"
                    )
                    self.streakManager = manager
                }
            }
        }
    }

    private var tabContent: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                TopicsView()
            }
            .tabItem { Label("Learn", systemImage: "graduationcap.fill") }

            NavigationStack {
                BibleView()
            }
            .tabItem { Label("Bible", systemImage: "book.fill") }

            NavigationStack {
                JournalView()
            }
            .tabItem { Label("Journal", systemImage: "square.and.pencil") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.preview)
        .environmentObject(PremiumManager.preview)
        .modelContainer(PreviewContainer.shared)
}
