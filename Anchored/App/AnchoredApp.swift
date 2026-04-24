//
//  AnchoredApp.swift
//  Anchored
//
//  App entry point. Sets up the SwiftData container for all persisted
//  models and injects environment objects used app-wide.
//

import SwiftUI
import SwiftData

@main
struct AnchoredApp: App {

    // MARK: - SwiftData Container

    /// Shared model container for all persisted types. If the SwiftData
    /// store can't be created (rare — usually disk full or schema corrupt),
    /// we fall back to an in-memory container so the app still launches.
    let modelContainer: ModelContainer = {
        let schema = Schema([
            LessonProgress.self,
            UserStreak.self,
            BibleNote.self,
            Prayer.self,
            SavedVerse.self,
            UserSettings.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            assertionFailure("SwiftData container failed: \(error). Falling back to in-memory.")
            let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            // Force unwrap is acceptable here — if even the in-memory store fails,
            // the app is unusable and we want to crash loudly in development.
            return try! ModelContainer(for: schema, configurations: [memConfig])
        }
    }()

    // MARK: - Shared Services

    @StateObject private var authManager = AuthManager()
    @StateObject private var premiumManager = PremiumManager()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(premiumManager)
                .tint(AnchoredColors.amber)
        }
        .modelContainer(modelContainer)
    }
}
