//
//  SubscriptionGate.swift
//  pdd
//
//  Source of truth for the `premium` entitlement.
//
//  In production this mirrors RevenueCat's active entitlements. The RevenueCat
//  SDK is an external dependency, so the default build runs in guest mode
//  (no premium). Drop in the SDK and implement `refresh()` / `purchase()` /
//  `restore()` against `Purchases.shared` to go live — call sites already exist.
//

import Foundation
import Observation

@Observable
final class SubscriptionGate {
    static let shared = SubscriptionGate()
    private init() {}

    /// True when the user holds the `premium` entitlement.
    private(set) var isPremium = false

    /// TODO(RevenueCat): set from `Purchases.shared.customerInfo`.
    func refresh() async { /* await RevenueCat customerInfo → isPremium */ }

    /// TODO(RevenueCat): `Purchases.shared.purchase(package:)`.
    func purchase(productId: String) async throws { }

    /// TODO(RevenueCat): `Purchases.shared.restorePurchases()`.
    func restore() async throws { }

    #if DEBUG
    func debugSetPremium(_ value: Bool) { isPremium = value }
    #endif
}

/// Catalog of the two subscription products (spec §12).
enum SubscriptionProduct: String, CaseIterable {
    case weekly = "pdd_weekly_990"
    case monthly = "pdd_monthly_2490"

    var period: String { self == .weekly ? "неделя" : "месяц" }
    var price: String { self == .weekly ? "990 ₸" : "2490 ₸" }
    var isBestValue: Bool { self == .monthly }
}
