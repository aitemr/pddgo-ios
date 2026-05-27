//
//  StreakStore.swift
//  pdd
//
//  Tracks the user's daily activity streak. A "fire day" is any day on
//  which the user completed at least one quiz / answered questions.
//

import Foundation
import Observation

@Observable
final class StreakStore {
    static let shared = StreakStore()

    private enum Key {
        static let current = "streak_current_v1"
        static let longest = "streak_longest_v1"
        static let lastActiveDay = "streak_last_active_day_v1"
    }

    private(set) var current: Int
    private(set) var longest: Int
    private(set) var lastActiveDay: Date?

    private init() {
        let d = SharedDefaults.current
        current = d.integer(forKey: Key.current)
        longest = d.integer(forKey: Key.longest)
        lastActiveDay = d.object(forKey: Key.lastActiveDay) as? Date
    }

    /// Call once after each completed quiz session.
    func recordActivity(on date: Date = Date()) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)

        if let last = lastActiveDay {
            let lastDay = cal.startOfDay(for: last)
            if cal.isDate(today, inSameDayAs: lastDay) {
                return // already counted today
            }
            let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
            if cal.isDate(lastDay, inSameDayAs: yesterday) {
                current += 1
            } else {
                current = 1
            }
        } else {
            current = 1
        }

        longest = max(longest, current)
        lastActiveDay = today
        persist()
        WidgetSnapshot.write()
    }

    /// True if the user already has activity recorded for today.
    func isActiveToday(_ date: Date = Date()) -> Bool {
        guard let last = lastActiveDay else { return false }
        return Calendar.current.isDate(last, inSameDayAs: date)
    }

    /// Mon..Sun fire booleans for the current ISO week (Mon=0).
    func weekFires(for date: Date = Date()) -> [Bool] {
        guard current > 0, let last = lastActiveDay else {
            return Array(repeating: false, count: 7)
        }
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        // The streak ends on `last`; mark the last `current` consecutive days
        // up to and including `last`, but only those that fall in this week.
        var result = Array(repeating: false, count: 7)
        for offset in 0..<current {
            guard let day = cal.date(byAdding: .day, value: -offset, to: last) else { continue }
            let dayStart = cal.startOfDay(for: day)
            let diff = cal.dateComponents([.day], from: weekStart, to: dayStart).day ?? -1
            if (0..<7).contains(diff) { result[diff] = true }
        }
        return result
    }

    private func persist() {
        let d = SharedDefaults.current
        d.set(current, forKey: Key.current)
        d.set(longest, forKey: Key.longest)
        d.set(lastActiveDay, forKey: Key.lastActiveDay)
    }
}
