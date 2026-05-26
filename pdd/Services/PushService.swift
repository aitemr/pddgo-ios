//
//  PushService.swift
//  pdd
//
//  Notification permission + token handling. APNs permission works natively;
//  FCM token registration is a Firebase SDK concern (spec §16) and is stubbed.
//

import Foundation
import UserNotifications
import UIKit

final class PushService {
    static let shared = PushService()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
                // TODO(FCM): retrieve and upload the FCM token.
            }
            return granted
        } catch { return false }
    }

    func disable() {
        // TODO(FCM): delete the FCM token on toggle-off.
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}

/// Lightweight haptics, gated by the session toggle.
enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard Session.shared.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard Session.shared.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
