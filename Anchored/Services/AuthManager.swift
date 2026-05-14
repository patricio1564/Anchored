//
//  AuthManager.swift
//  Anchored
//
//  Authentication state holder backed by Sign in with Apple.
//  - User identifier and display name are both persisted to Keychain
//    (survives app re-installs as long as the device hasn't been wiped).
//    Apple only returns the display name on the first successful sign-in,
//    so we cache it ourselves in the Keychain.
//  - On launch we verify the stored credential is still valid with
//    ASAuthorizationAppleIDProvider before restoring .signedIn state.
//

import Foundation
import Combine
import AuthenticationServices
import Security
import SwiftData

@MainActor
final class AuthManager: ObservableObject {

    enum State: Equatable {
        /// We haven't checked keychain yet — show splash.
        case unknown
        /// No credential on file — show onboarding.
        case signedOut
        /// Signed in. `userId` is the Apple credential identifier.
        case signedIn(userId: String, displayName: String?)
    }

    @Published private(set) var state: State = .unknown

    /// The current user identifier, or nil if signed out.
    var currentUserId: String? {
        if case .signedIn(let id, _) = state { return id }
        return nil
    }

    init() {
        Task { @MainActor in
            await restoreSession()
        }
    }

    /// Called from OnboardingView after a successful ASAuthorization.
    func completeSignIn(userId: String, displayName: String?) {
        saveToKeychain(value: userId, account: Self.keychainAccount)
        if let displayName {
            saveToKeychain(value: displayName, account: Self.displayNameAccount)
        }
        state = .signedIn(userId: userId, displayName: displayName)
    }

    /// Sign out — clears keychain and in-memory state. SwiftData rows are kept
    /// so signing back in on the same device restores progress.
    func signOut() {
        clearKeychain()
        state = .signedOut
    }

    /// Permanently delete the account: wipes all user-owned SwiftData rows
    /// (locally and via CloudKit sync), clears the stored Apple credential
    /// from Keychain, and resets state to `.signedOut`.
    ///
    /// Apple's Sign in with Apple revocation endpoint is server-side only
    /// and would require a backend with the team's private key. The caller
    /// should follow this up by pointing the user to Settings → Apple ID →
    /// Sign-In & Security → Apps Using Apple ID to revoke the credential.
    func deleteAccount(context: ModelContext) throws {
        try context.delete(model: LessonProgress.self)
        try context.delete(model: UserStreak.self)
        try context.delete(model: BibleNote.self)
        try context.delete(model: Prayer.self)
        try context.delete(model: SavedVerse.self)
        try context.delete(model: UserSettings.self)
        try context.save()

        clearKeychain()
        state = .signedOut
    }

    private func clearKeychain() {
        deleteFromKeychain(account: Self.keychainAccount)
        deleteFromKeychain(account: Self.displayNameAccount)
    }

    // MARK: - Session restore

    private func restoreSession() async {
        guard let userId = loadFromKeychain() else {
            state = .signedOut
            return
        }

        // Verify Apple still considers this credential valid.
        let provider = ASAuthorizationAppleIDProvider()
        let credentialState = (try? await provider.credentialState(forUserID: userId)) ?? .revoked

        if credentialState == .authorized {
            let displayName = loadFromKeychain(account: Self.displayNameAccount)
            state = .signedIn(userId: userId, displayName: displayName)
        } else {
            // Revoked or transferred — treat as signed out.
            deleteFromKeychain()
            state = .signedOut
        }
    }

    // MARK: - Keychain

    private static let keychainAccount    = "anchored.apple-user-id"
    private static let displayNameAccount = "anchored.display-name"

    private func saveToKeychain(value: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass:              kSecClassGenericPassword,
            kSecAttrAccount:        account,
            kSecValueData:          data,
            kSecAttrAccessible:     kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain(account: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain(account: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func loadFromKeychain() -> String? {
        loadFromKeychain(account: Self.keychainAccount)
    }

    private func deleteFromKeychain() {
        deleteFromKeychain(account: Self.keychainAccount)
    }
}

// MARK: - Previews

@MainActor
extension AuthManager {
    static var preview: AuthManager {
        let m = AuthManager()
        m.state = .signedIn(userId: "00000000-0000-0000-0000-000000000000", displayName: "Preview User")
        return m
    }
}
