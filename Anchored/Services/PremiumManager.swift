//
//  PremiumManager.swift
//  Anchored
//
//  StoreKit 2 entitlement manager. Owns the premium state and all
//  purchase/restore logic. Views only read `isPremium` and call
//  `presentPaywall()` — that interface is intentionally stable so no
//  view changes are needed when switching between stub and real SKs.
//
//  ─── Setup ──────────────────────────────────────────────────────────────
//  1. Create products in App Store Connect:
//       Your App → Monetization → Subscriptions → "+"
//       - Auto-renewing monthly: com.anchored.app.premium.monthly
//       - Auto-renewing yearly:  com.anchored.app.premium.yearly
//  2. Add a StoreKit Configuration file for local testing with both IDs.
//  ────────────────────────────────────────────────────────────────────────

import Foundation
import Combine
import StoreKit

@MainActor
final class PremiumManager: ObservableObject {

    static let monthlyProductID = "com.anchored.app.premium.monthly"
    static let yearlyProductID  = "com.anchored.app.premium.yearly"

    private static let validOfferCodes: Set<String> = [
        "ANCHORED-BETA",
        "FRIENDS2024",
        "FAMILY2024"
    ]
    private static let redeemedCodeKey = "anchoredRedeemedOfferCode"

    enum Plan { case monthly, yearly }

    enum RedeemResult { case success, invalid, alreadyRedeemed }

    // MARK: - Published state

    @Published private(set) var isPremium: Bool = false
    @Published var isShowingPaywall: Bool = false
    @Published private(set) var monthlyProduct: Product?
    @Published private(set) var yearlyProduct: Product?
    @Published private(set) var purchaseState: PurchaseState = .idle

    /// Convenience for callers that only need one product reference (e.g. old PaywallSheet).
    var product: Product? { yearlyProduct ?? monthlyProduct }

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case failed(String)

        static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.purchasing, .purchasing): return true
            case (.failed(let a), .failed(let b)): return a == b
            default: return false
            }
        }
    }

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init / deinit

    init() {
        transactionListener = makeTransactionListener()
        Task {
            await checkEntitlements()
            await fetchProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public interface

    func presentPaywall() {
        isShowingPaywall = true
    }

    func purchase(_ plan: Plan = .yearly) async {
        let product = plan == .yearly ? yearlyProduct : monthlyProduct
        guard let product else { return }
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkEntitlements()
                purchaseState = .idle
                isShowingPaywall = false
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func redeemOfferCode(_ code: String) -> RedeemResult {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalized.isEmpty else { return .invalid }
        if UserDefaults.standard.string(forKey: Self.redeemedCodeKey) != nil {
            return .alreadyRedeemed
        }
        guard Self.validOfferCodes.contains(normalized) else {
            return .invalid
        }
        UserDefaults.standard.set(normalized, forKey: Self.redeemedCodeKey)
        isPremium = true
        isShowingPaywall = false
        return .success
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            // Sync can fail if the user cancels the Apple ID prompt — ignore.
        }
    }

    // MARK: - Private

    private func fetchProducts() async {
        let ids = [Self.monthlyProductID, Self.yearlyProductID]
        guard let products = try? await Product.products(for: ids) else { return }
        for p in products {
            if p.id == Self.monthlyProductID { monthlyProduct = p }
            if p.id == Self.yearlyProductID  { yearlyProduct  = p }
        }
    }

    private func checkEntitlements() async {
        var hasAccess = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            let knownIDs = [Self.monthlyProductID, Self.yearlyProductID]
            if knownIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                hasAccess = true
            }
        }
        if UserDefaults.standard.string(forKey: Self.redeemedCodeKey) != nil {
            hasAccess = true
        }
        isPremium = hasAccess
    }

    private func makeTransactionListener() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.checkEntitlements()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    // MARK: - Debug

    #if DEBUG
    func debugUnlock() { isPremium = true }
    func debugLock()   { isPremium = false }
    #endif
}

// MARK: - Previews

@MainActor
extension PremiumManager {
    static var preview: PremiumManager { PremiumManager() }

    static var previewPremium: PremiumManager {
        let m = PremiumManager()
        #if DEBUG
        m.debugUnlock()
        #endif
        return m
    }
}
