//
//  Session.swift
//  pdd
//
//  Current user + persisted settings. The session is stored in UserDefaults
//  here; production should keep tokens in Keychain (spec §0).
//

import Foundation
import Observation

enum AuthProvider: String, Codable { case google, apple, demo }

struct UserInfo: Codable {
    var id: String                 // Firebase UID (or "guest")
    var firstName: String
    var lastName: String
    var phone: String
    var licenseCategory: String    // "Категория B", …
    var photoUrl: String
    var provider: AuthProvider

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }

    static let guest = UserInfo(
        id: "guest", firstName: "Гость", lastName: "", phone: "",
        licenseCategory: "Категория B", photoUrl: "", provider: .demo
    )
}

@Observable
final class Session {
    static let shared = Session()

    private init() {
        user = Store.decode(UserInfo.self, StorageKey.session)
        isLoggedIn = Store.bool(StorageKey.isLoggedIn)
        funnelCompleted = Store.bool(StorageKey.funnelCompleted)
        let raw = Store.string(StorageKey.lang) ?? AppLanguage(rawValue: Locale.current.language.languageCode?.identifier ?? "")?.rawValue ?? "kk"
        language = AppLanguage(rawValue: raw) ?? .kk
        notificationsEnabled = Store.bool(StorageKey.notificationsEnabled)
        hapticsEnabled = UserDefaults.standard.object(forKey: StorageKey.hapticsEnabled) as? Bool ?? true
        animationsEnabled = UserDefaults.standard.object(forKey: StorageKey.animationsEnabled) as? Bool ?? true
    }

    var user: UserInfo?
    var isLoggedIn: Bool { didSet { Store.set(isLoggedIn, StorageKey.isLoggedIn) } }
    var funnelCompleted: Bool { didSet { Store.set(funnelCompleted, StorageKey.funnelCompleted) } }
    var language: AppLanguage { didSet { Store.set(language.rawValue, StorageKey.lang) } }
    var notificationsEnabled: Bool { didSet { Store.set(notificationsEnabled, StorageKey.notificationsEnabled) } }
    var hapticsEnabled: Bool { didSet { Store.set(hapticsEnabled, StorageKey.hapticsEnabled) } }
    var animationsEnabled: Bool { didSet { Store.set(animationsEnabled, StorageKey.animationsEnabled) } }

    var displayUser: UserInfo { user ?? .guest }

    func update(user: UserInfo) {
        self.user = user
        Store.encode(user, StorageKey.session)
    }

    func clear() {
        user = nil
        isLoggedIn = false
        Store.remove(StorageKey.session)
    }
}
