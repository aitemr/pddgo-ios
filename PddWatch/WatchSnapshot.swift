//
//  WatchSnapshot.swift
//  PddWatch
//
//  Mirror of the phone's WidgetSnapshot, received over WatchConnectivity and
//  cached locally so the watch shows the last-known streak on cold launch.
//

import Foundation

struct WatchSnapshot: Codable {
    var correctTotal: Int
    var answeredTotal: Int
    var questionBankTotal: Int
    var currentStreak: Int
    var longestStreak: Int
    var isActiveToday: Bool
    var updatedAt: Date

    static let storageKey = "watch_snapshot_v1"

    static let empty = WatchSnapshot(
        correctTotal: 0, answeredTotal: 0, questionBankTotal: 0,
        currentStreak: 0, longestStreak: 0, isActiveToday: false, updatedAt: Date()
    )

    static func load() -> WatchSnapshot {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snap = try? JSONDecoder().decode(WatchSnapshot.self, from: data)
        else { return .empty }
        return snap
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
