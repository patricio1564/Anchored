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

        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            print("[Anchored] CloudKit container init failed (\(error)). Falling back to local store.")
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                print("[Anchored] SwiftData local container also failed: \(error). Using in-memory.")
                let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try! ModelContainer(for: schema, configurations: [memConfig])
            }
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
