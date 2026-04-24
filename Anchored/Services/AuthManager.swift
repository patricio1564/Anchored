//
//  AuthManager.swift
//  Anchored
//
//  Authentication state holder backed by Sign in with Apple.
//  - User identifier is persisted to Keychain (survives app re-installs
//    as long as the device hasn't been wiped).
//  - Display name is stored in UserDefaults (Apple only returns it on
//    the *first* successful sign-in, so we cache it ourselves).
//  - On launch we verify the stored credential is still valid with
//    ASAuthorizationAppleIDProvider before restoring .signedIn state.
//

import Foundation
import Combine
import AuthenticationServices
import Security

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
        saveToKeychain(userId: userId)
        if let displayName {
            UserDefaults.standard.set(displayName, forKey: Self.displayNameKey)
        }
        state = .signedIn(userId: userId, displayName: displayName)
    }

    /// Sign out — clears keychain and in-memory state. SwiftData rows are kept
    /// so signing back in on the same device restores progress.
    func signOut() {
        deleteFromKeychain()
        UserDefaults.standard.removeObject(forKey: Self.displayNameKey)
        state = .signedOut
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
            let displayName = UserDefaults.standard.string(forKey: Self.displayNameKey)
            state = .signedIn(userId: userId, displayName: displayName)
        } else {
            // Revoked or transferred — treat as signed out.
            deleteFromKeychain()
            state = .signedOut
        }
    }

    // MARK: - Keychain

    private static let keychainAccount = "anchored.apple-user-id"
    private static let displayNameKey  = "anchored.display-name"

    private func saveToKeychain(userId: String) {
        guard let data = userId.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: Self.keychainAccount,
            kSecValueData:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: Self.keychainAccount,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain() {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: Self.keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Previews

@MainActor
extension AuthManager {
    static var preview: AuthManager {
        let m = AuthManager()
        m.state = .signedIn(userId: "preview-user", displayName: "Patrick")
        return m
    }
}
