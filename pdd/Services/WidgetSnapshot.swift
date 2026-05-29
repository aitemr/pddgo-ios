//
//  WidgetSnapshot.swift
//  pdd
//
//  Compact, Codable view of progress + streak written to the shared
//  UserDefaults suite after every quiz completion. The widget extension
//  (future PR) consumes this directly.
//

import Foundation
import WidgetKit

struct WidgetSnapshot: Codable {
    let correctTotal: Int
    let answeredTotal: Int
    let questionBankTotal: Int
    let currentStreak: Int
    let longestStreak: Int
    let isActiveToday: Bool
    let updatedAt: Date

    static let storageKey = "widget_snapshot_v1"

    static func current() -> WidgetSnapshot {
        WidgetSnapshot(
            correctTotal: ProgressStore.shared.correctTotal,
            answeredTotal: ProgressStore.shared.answeredTotal,
            questionBankTotal: QuizRules.questionBankTotal,
            currentStreak: StreakStore.shared.current,
            longestStreak: StreakStore.shared.longest,
            isActiveToday: StreakStore.shared.isActiveToday(),
            updatedAt: Date()
        )
    }

    /// Persists the current state for the widget to read.
    static func write() {
        let snapshot = current()
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        SharedDefaults.current.set(data, forKey: storageKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Reads the latest snapshot from shared storage.
    static func read() -> WidgetSnapshot? {
        guard let data = SharedDefaults.current.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
