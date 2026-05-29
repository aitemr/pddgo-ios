//
//  WatchSession.swift
//  PddWatch
//
//  Watch side of the phone↔watch bridge. Receives the latest snapshot via
//  WatchConnectivity application context and publishes it to the UI.
//

import Foundation
import Observation
import WatchConnectivity

@Observable
final class WatchSession: NSObject, WCSessionDelegate {
    static let shared = WatchSession()

    var snapshot: WatchSnapshot

    private override init() {
        snapshot = WatchSnapshot.load()
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func apply(_ context: [String: Any]) {
        guard !context.isEmpty,
              let data = try? JSONSerialization.data(withJSONObject: context),
              let snap = try? JSONDecoder().decode(WatchSnapshot.self, from: data)
        else { return }
        Task { @MainActor in
            self.snapshot = snap
            snap.save()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // A context may have been delivered before we activated.
        apply(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        apply(applicationContext)
    }
}
