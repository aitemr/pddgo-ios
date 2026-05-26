//
//  RootView.swift
//  pdd
//

import SwiftUI

struct RootView: View {
    @State private var app = AppState.shared

    var body: some View {
        ZStack {
            switch app.route {
            case .splash:     SplashView()
            case .onboarding: OnboardingFlow()
            case .paywall:    PaywallView(canDismiss: false)
            case .main:       MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.26), value: routeKey)
        .environment(app)
    }

    private var routeKey: Int {
        switch app.route {
        case .splash: 0; case .onboarding: 1; case .paywall: 2; case .main: 3
        }
    }
}

#Preview { RootView() }
