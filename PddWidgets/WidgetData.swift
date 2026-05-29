//
//  WidgetData.swift
//  PddWidgets
//
//  Self-contained mirror of the app's WidgetSnapshot. The main app writes the
//  snapshot (Services/WidgetSnapshot.swift) to the shared App Group suite after
//  every quiz finish; the widget decodes the same bytes here. Field names and
//  the storage key MUST stay in sync with the app's struct.
//

import Foundation
import SwiftUI

enum WidgetAppGroup {
    static let id = "group.com.zimran.pdd"
}

struct PddSnapshot: Codable {
    let correctTotal: Int
    let answeredTotal: Int
    let questionBankTotal: Int
    let currentStreak: Int
    let longestStreak: Int
    let isActiveToday: Bool
    let updatedAt: Date

    static let storageKey = "widget_snapshot_v1"

    var ratio: Double {
        guard questionBankTotal > 0 else { return 0 }
        return min(1, Double(correctTotal) / Double(questionBankTotal))
    }

    static func read() -> PddSnapshot? {
        let defaults = UserDefaults(suiteName: WidgetAppGroup.id) ?? .standard
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(PddSnapshot.self, from: data)
    }

    /// Shown in the widget gallery / before any quiz has been completed.
    static let placeholder = PddSnapshot(
        correctTotal: 124, answeredTotal: 160, questionBankTotal: 848,
        currentStreak: 5, longestStreak: 12, isActiveToday: true, updatedAt: Date()
    )
}

// Brand palette (kept local; the app's Theme isn't a member of this target).
extension Color {
    static let pddBlue = Color(red: 0x1B / 255, green: 0x8F / 255, blue: 0xEF / 255)
    static let pddOrange = Color(red: 0xFC / 255, green: 0xB6 / 255, blue: 0x14 / 255)
}
