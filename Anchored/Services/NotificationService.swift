// ────────────────────────────────────────────────────────────────────────────
// NotificationService.swift
//
// Local-only notification scheduling for the daily verse reminder.
// Uses UNUserNotificationCenter with a DateComponents-based trigger
// so the OS handles the recurring daily schedule natively.
//
// ─────────────────────── PERMISSION PHILOSOPHY ─────────────────────────────
//
// We NEVER prompt for notification permission at launch. First launch
// is a moment of curiosity — asking for a scary OS-level permission
// immediately breaks the spell. Instead, we prompt contextually:
//
//   • After the user manually enables "Daily reminder" in Profile.
//   • After the user completes their first lesson and sees the streak
//     celebration, if they tap "Remind me to come back tomorrow".
//
// If the user has previously denied permission, we detect it and route
// them to the system settings deep-link instead of showing a useless
// second prompt that iOS would silently no-op.
// ────────────────────────────────────────────────────────────────────────────

import Foundation
import UIKit
import UserNotifications

@MainActor
final class NotificationService {

    /// Singleton because UNUserNotificationCenter is itself a singleton
    /// and there's no reason to have multiple wrappers.
    static let shared = NotificationService()
    private init() {}

    /// Stable identifier for the recurring daily reminder. Reusing the
    /// same ID means scheduling twice just updates the existing request
    /// rather than creating duplicates.
    private let dailyReminderID = "anchored.daily-verse-reminder"

    private let center = UNUserNotificationCenter.current()

    // MARK: - Authorization

    /// Current authorization status. Async because UN's API is async.
    func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    /// Request permission. Returns true iff the user granted it.
    /// Callers should only invoke this from a contextual moment, not at launch.
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            // UNUserNotificationCenter throws on simulator in rare edge cases;
            // a false return is the safe answer — UI shows the off state.
            return false
        }
    }

    // MARK: - Scheduling

    /// Schedule (or re-schedule) the daily verse reminder at the given hour/minute
    /// in the user's current time zone. Replaces any existing reminder.
    ///
    /// - Parameters:
    ///   - hour: 0...23
    ///   - minute: 0...59
    ///
    /// Returns true on success. False means either no permission or the
    /// time inputs were invalid — caller should surface an error.
    @discardableResult
    func scheduleDailyReminder(hour: Int, minute: Int) async -> Bool {
        guard (0...23).contains(hour), (0...59).contains(minute) else {
            return false
        }

        let status = await currentAuthorizationStatus()
        guard status == .authorized || status == .provisional else {
            return false
        }

        // Clear any existing schedule first so we don't accumulate.
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Today's Verse"
        content.body = "Take a quiet moment. Your verse is waiting."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyReminderID,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    /// Cancel the recurring daily reminder.
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
    }

    /// Has the user already scheduled a daily reminder? Useful for
    /// reflecting state in the Profile settings toggle without
    /// storing a separate UserDefaults flag.
    func isDailyReminderScheduled() async -> Bool {
        let pending = await center.pendingNotificationRequests()
        return pending.contains { $0.identifier == dailyReminderID }
    }

    // MARK: - Settings deep-link

    /// URL for iOS Settings → Anchored. Safe to pass to UIApplication.open
    /// to route a denied user to the system-level toggle.
    var settingsURL: URL? {
        URL(string: UIApplication.openSettingsURLString)
    }
}
