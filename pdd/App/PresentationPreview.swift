import SwiftUI

#if DEBUG
struct PresentationPreviewHost: View {
    enum Screen {
        case tests
        case akzhol
        case profile
        case paywall
        case onboarding
    }

    let screen: Screen

    var body: some View {
        Group {
            switch screen {
            case .tests:
                TestsRootView()
            case .akzhol:
                AkzholRootView()
            case .profile:
                ProfileRootView()
                    .environment(AppState.shared)
            case .paywall:
                PaywallView(canDismiss: true)
                    .environment(AppState.shared)
            case .onboarding:
                OnboardingFlow()
                    .environment(AppState.shared)
            }
        }
    }
}

#Preview("Tests") {
    PresentationPreviewHost(screen: .tests)
}

#Preview("Akzhol") {
    PresentationPreviewHost(screen: .akzhol)
}

#Preview("Profile") {
    PresentationPreviewHost(screen: .profile)
}

#Preview("Paywall") {
    PresentationPreviewHost(screen: .paywall)
}

#Preview("Onboarding") {
    PresentationPreviewHost(screen: .onboarding)
}
#endif
