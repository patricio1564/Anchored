// ────────────────────────────────────────────────────────────────────────────
// VerseNotificationScheduler.swift
//
// Manages rich daily verse notifications with actual verse text in the user's
// preferred translation, pre-fetched by a nightly background task.
//
// Architecture:
//   • NotificationService schedules a *recurring* fallback notification at
//     HH:mm with generic body text. That fires even if this scheduler never
//     runs — the user always gets a reminder.
//   • This scheduler adds a *dated* notification (ID: anchored.daily-verse-
//     YYYY-MM-DD) that fires 1 second before the fallback and includes the
//     full verse text + reference as subtitle. When both are pending, iOS
//     delivers the one that fires first (the dated one).
//   • A BGAppRefreshTask (com.anchored.verse-fetch) runs nightly ~2 AM to
//     pre-fetch tomorrow's verse and schedule its dated notification.
//   • scheduleIfNeeded() is called on every foreground resume and at app
//     launch as a safety net in case the background task didn't fire.
//
// IMPORTANT: Before submitting to App Store, add the background task
// identifier to Info.plist (or project.yml):
//   Key:   BGTaskSchedulerPermittedIdentifiers
//   Value: com.anchored.verse-fetch
// ────────────────────────────────────────────────────────────────────────────

import Foundation
import UserNotifications
import SwiftData

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

final class VerseNotificationScheduler {

    static let shared = VerseNotificationScheduler()

    #if canImport(BackgroundTasks)
    static let backgroundTaskID = "com.anchored.verse-fetch"
    #endif

    private init() {}

    // Set once at app launch via configure(with:). Never mutated after that.
    private var modelContainer: ModelContainer?

    // MARK: - Configuration

    func configure(with container: ModelContainer) {
        modelContainer = container
    }

    // MARK: - Background task registration

    /// Register the BGAppRefreshTask handler. Must be called in App.init(),
    /// before applicationDidFinishLaunching completes.
    func registerBackgroundTask() {
        #if canImport(BackgroundTasks)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.backgroundTaskID,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            Task { await Self.shared.handleAppRefresh(task: refreshTask) }
        }
        #endif
    }

    // MARK: - Background task handler

    #if canImport(BackgroundTasks)
    private func handleAppRefresh(task: BGAppRefreshTask) async {
        // Keep the chain alive immediately — submit next request before doing work
        // so a crash or expiry doesn't break tomorrow's cycle.
        scheduleNextBackgroundFetch()

        let work = Task { await scheduleNotificationForTomorrow() }
        task.expirationHandler = { work.cancel() }

        await work.value
        task.setTaskCompleted(success: !work.isCancelled)
    }
    #endif

    // MARK: - Schedule next background fetch

    /// Submit a BGAppRefreshTaskRequest targeting ~2 AM tomorrow.
    /// iOS honors the earliestBeginDate as a lower bound; actual fire time
    /// depends on device usage patterns and battery state.
    func scheduleNextBackgroundFetch() {
        #if canImport(BackgroundTasks)
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskID)
        request.earliestBeginDate = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 2, minute: 0),
            matchingPolicy: .nextTime
        )
        try? BGTaskScheduler.shared.submit(request)
        #endif
    }

    // MARK: - Public scheduling entry points

    /// Safety net: schedule today's dated verse notification if it isn't
    /// already pending and the scheduled time hasn't passed yet.
    /// Call from foreground resume (scenePhase → .active) and at app launch.
    func scheduleIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized ||
              settings.authorizationStatus == .provisional else { return }

        let today = Date()
        let todayID = notificationID(for: today)
        let pending = await center.pendingNotificationRequests()
        guard !pending.contains(where: { $0.identifier == todayID }) else { return }

        await scheduleNotification(for: today)
    }

    /// Pre-fetch tomorrow's verse and schedule its dated notification.
    /// Called by the background task handler.
    func scheduleNotificationForTomorrow() async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        await scheduleNotification(for: tomorrow)
    }

    /// Remove and re-schedule both today's and tomorrow's dated notifications.
    /// Call when the user changes their reminder time or Bible translation so
    /// the pending notifications reflect the new settings.
    func rescheduleDatedNotifications() async {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            notificationID(for: today),
            notificationID(for: tomorrow)
        ])

        await scheduleNotification(for: today)
        await scheduleNotification(for: tomorrow)
    }

    // MARK: - Core scheduling

    private func scheduleNotification(for date: Date) async {
        guard let reminderTime = await fetchReminderTime() else { return }

        // Compute fire time: 1 second before the recurring fallback so this
        // notification appears first in the lock screen / notification center.
        let totalSeconds = reminderTime.hour * 3600 + reminderTime.minute * 60 - 1
        let clampedSeconds = max(0, totalSeconds)
        var dateComps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComps.hour   = clampedSeconds / 3600
        dateComps.minute = (clampedSeconds % 3600) / 60
        dateComps.second = clampedSeconds % 60

        // Don't schedule if the fire moment is already in the past — iOS would
        // deliver it immediately, which is surprising UX.
        if let fireDate = Calendar.current.date(from: dateComps), fireDate <= Date() { return }

        let verse = DailyVerses.verse(for: date)
        let translation = await fetchPreferredTranslation()

        // Fetch the verse in the user's translation; fall back to curated WEB text.
        let verseText: String
        if translation == .web {
            verseText = verse.text
        } else if let passage = try? await BibleAPIService.shared.fetch(
            reference: verse.reference,
            translation: translation
        ) {
            verseText = passage.text
        } else {
            verseText = verse.text
        }

        let content = UNMutableNotificationContent()
        content.title    = "Today's Verse"
        content.subtitle = verse.reference
        content.body     = verseText
        content.sound    = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)
        let request  = UNNotificationRequest(
            identifier: notificationID(for: date),
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Helpers

    private func notificationID(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "anchored.daily-verse-\(formatter.string(from: date))"
    }

    private func fetchPreferredTranslation() async -> BibleTranslation {
        guard let container = modelContainer else { return .web }
        let context = ModelContext(container)
        guard
            let settings = try? context.fetch(FetchDescriptor<UserSettings>()).first,
            let translation = BibleTranslation(rawValue: settings.preferredTranslation)
        else { return .web }
        return translation
    }

    private func fetchReminderTime() async -> (hour: Int, minute: Int)? {
        guard let container = modelContainer else { return nil }
        let context = ModelContext(container)
        guard
            let settings = try? context.fetch(FetchDescriptor<UserSettings>()).first,
            settings.notificationsEnabled,
            let timeStr = settings.dailyReminderTime
        else { return nil }
        let parts = timeStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}
