//
//  PhoneWatchSync.swift
//  pdd
//
//  iPhone side of the phone↔watch bridge. App Groups don't cross devices, so
//  the watch can't read the shared UserDefaults suite directly — we push the
//  latest WidgetSnapshot to the watch via WatchConnectivity's application
//  context (last-value-wins, delivered opportunistically in the background).
//

import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity

final class PhoneWatchSync: NSObject, WCSessionDelegate {
    static let shared = PhoneWatchSync()
    private override init() { super.init() }

    /// Call once at app launch.
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Push the latest snapshot to the watch. Safe to call even with no paired
    /// watch — it simply no-ops.
    func send(_ snapshot: WidgetSnapshot) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(snapshot),
              let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        else { return }
        try? session.updateApplicationContext(dict)
    }

    // MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}
#endif
