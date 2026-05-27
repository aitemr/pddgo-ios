//
//  FirebaseAuthService.swift
//  pdd
//
//  Real authentication: Google (GoogleSignIn) and Apple (AuthenticationServices)
//  bridged through Firebase Auth. Faithful port of firebase_social_auth.dart.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import UIKit

final class FirebaseAuthService: NSObject, AuthService {
    static let shared = FirebaseAuthService()
    private override init() { super.init() }

    // Apple sign-in is delegate-based; bridge it to async/await.
    private var appleContinuation: CheckedContinuation<UserInfo, Error>?
    private var currentNonce: String?

    func signIn(with provider: AuthProvider) async throws -> UserInfo {
        switch provider {
        case .google: return try await signInWithGoogle()
        case .apple:  return try await signInWithApple()
        case .demo:   return .guest
        }
    }

    func signOut() async {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
        } catch let error as NSError where error.code == AuthErrorCode.requiresRecentLogin.rawValue {
            // Re-authenticate, then retry deletion (Firebase security requirement).
            let providerId = user.providerData.first?.providerID
            if providerId == "google.com" {
                let cred = try await googleCredential()
                try await user.reauthenticate(with: cred)
            } else if providerId == "apple.com" {
                _ = try await signInWithApple() // fresh Apple credential establishes recent login
            }
            try await user.delete()
        }
        await signOut()
    }

    // MARK: - Google

    @MainActor
    private func signInWithGoogle() async throws -> UserInfo {
        let cred = try await googleCredential()
        let result = try await Auth.auth().signIn(with: cred)
        return Self.userInfo(from: result.user, provider: .google)
    }

    @MainActor
    private func googleCredential() async throws -> AuthCredential {
        guard let presenter = Self.topViewController() else {
            throw AuthError.failed("Нет активного окна для входа.")
        }
        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        } catch let error as NSError {
            if error.code == GIDSignInError.canceled.rawValue { throw AuthError.cancelled }
            throw AuthError.failed(error.localizedDescription)
        }
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.failed("Google не вернул idToken.")
        }
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
    }

    // MARK: - Apple

    @MainActor
    private func signInWithApple() async throws -> UserInfo {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        return try await withCheckedThrowingContinuation { continuation in
            self.appleContinuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - Mapping

    static func userInfo(
        from u: User,
        provider: AuthProvider,
        appleGiven: String? = nil,
        appleFamily: String? = nil
    ) -> UserInfo {
        var first = (appleGiven ?? "").trimmingCharacters(in: .whitespaces)
        var last = (appleFamily ?? "").trimmingCharacters(in: .whitespaces)

        if first.isEmpty, last.isEmpty,
           let display = u.displayName?.trimmingCharacters(in: .whitespaces), !display.isEmpty {
            let parts = display.split(separator: " ").map(String.init)
            first = parts.first ?? ""
            if parts.count > 1 { last = parts.dropFirst().joined(separator: " ") }
        }
        if first.isEmpty, let email = u.email, !email.isEmpty {
            first = String(email.split(separator: "@").first ?? "")
        }

        return UserInfo(
            id: u.uid,
            firstName: first,
            lastName: last,
            phone: u.phoneNumber ?? "",
            licenseCategory: "Категория B",
            photoUrl: u.photoURL?.absoluteString ?? "",
            provider: provider
        )
    }

    // MARK: - Helpers

    @MainActor
    static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        var top = scene?.keyWindow?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status != errSecSuccess { continue }
            if random < UInt8(charset.count) {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple delegate

extension FirebaseAuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let cont = appleContinuation else { return }
        appleContinuation = nil

        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            cont.resume(throwing: AuthError.failed("Apple не вернул identityToken."))
            return
        }

        let given = credential.fullName?.givenName
        let family = credential.fullName?.familyName
        let firebaseCred = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        Task {
            do {
                let result = try await Auth.auth().signIn(with: firebaseCred)
                cont.resume(returning: Self.userInfo(
                    from: result.user, provider: .apple, appleGiven: given, appleFamily: family
                ))
            } catch {
                cont.resume(throwing: AuthError.failed(error.localizedDescription))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let cont = appleContinuation else { return }
        appleContinuation = nil
        if (error as? ASAuthorizationError)?.code == .canceled {
            cont.resume(throwing: AuthError.cancelled)
        } else {
            cont.resume(throwing: AuthError.failed(error.localizedDescription))
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            Self.topViewController()?.view.window ?? ASPresentationAnchor()
        }
    }
}
