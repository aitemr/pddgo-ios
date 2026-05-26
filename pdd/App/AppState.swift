//
//  AppState.swift
//  pdd
//
//  Top-level routing (spec §18).
//

import SwiftUI
import Observation

enum AppRoute { case splash, onboarding, paywall, main }

@Observable
final class AppState {
    static let shared = AppState()
    private init() {}

    var route: AppRoute = .splash
    var selectedTab: PDDTab = .tests        // default opens on Tests (index 1)

    #if DEBUG
    /// Dev-only deep start, driven by launch defaults (used for verification).
    private func applyDebugStart() {
        if UserDefaults.standard.bool(forKey: "debug_start_main") {
            route = .main
            selectedTab = PDDTab(rawValue: UserDefaults.standard.integer(forKey: "debug_tab")) ?? .tests
        }
    }
    #endif

    /// Splash decision (spec §8.1).
    func resolveAfterSplash() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "debug_start_main") { applyDebugStart(); return }
        #endif
        let session = Session.shared
        if !session.isLoggedIn || !session.funnelCompleted {
            route = .onboarding
        } else if SubscriptionGate.shared.isPremium {
            route = .main
        } else {
            route = .paywall        // mandatory paywall
        }
    }

    func completeOnboarding() {
        Session.shared.isLoggedIn = true
        Session.shared.funnelCompleted = true
        route = SubscriptionGate.shared.isPremium ? .main : .paywall
    }

    func enterMain() { route = .main }

    func signOut() {
        Task { await LocalAuthService.shared.signOut() }
        Session.shared.clear()
        route = .onboarding
    }

    func deleteAccount() {
        Task { try? await LocalAuthService.shared.deleteAccount() }
        Session.shared.clear()
        route = .onboarding
    }
}
