//
//  AuthService.swift
//  pdd
//
//  Authentication abstraction. Google/Apple go through Firebase Auth in
//  production (external SDKs); the default build supports a fully-working
//  guest mode plus simulated social sign-in so the funnel runs end to end.
//

import Foundation

enum AuthError: Error { case cancelled, failed(String) }

protocol AuthService {
    func signIn(with provider: AuthProvider) async throws -> UserInfo
    func signOut() async
    func deleteAccount() async throws
}

/// Local implementation. Replace the social branches with Firebase/Google/Apple
/// (see spec §14) — the call sites in onboarding already await these.
final class LocalAuthService: AuthService {
    static let shared = LocalAuthService()
    private init() {}

    func signIn(with provider: AuthProvider) async throws -> UserInfo {
        // TODO: Firebase Auth + GoogleSignIn / Sign in with Apple (nonce).
        try await Task.sleep(nanoseconds: 400_000_000)
        let info = UserInfo(
            id: UUID().uuidString,
            firstName: provider == .apple ? "Apple" : provider == .google ? "Google" : "Гость",
            lastName: "Пользователь",
            phone: "",
            licenseCategory: "Категория B",
            photoUrl: "",
            provider: provider
        )
        // TODO: RevenueCat.logIn(uid) → SubscriptionGate.refresh()
        return info
    }

    func signOut() async {
        // TODO: Firebase signOut
    }

    func deleteAccount() async throws {
        // TODO: Firebase deleteAccount
    }
}
