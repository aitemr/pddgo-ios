//
//  TestHistory.swift
//  pdd
//
//  Trial-exam history (max 200 entries; 8 shown in preview).
//

import Foundation
import Observation

struct TestHistoryEntry: Codable, Identifiable {
    var id: Int { completedAtMillis }
    let quizModuleId: String          // trial_exam_kz | trial_exam_individual
    let score: Int
    let total: Int                    // 40
    let passed: Bool                  // score >= 32
    let completedAtMillis: Int
    let questionIds: [Int]
    let userChoices: [Int?]

    var canReplay: Bool { !questionIds.isEmpty && userChoices.count == questionIds.count }
    var completedDate: Date { Date(timeIntervalSince1970: Double(completedAtMillis) / 1000) }
}

@Observable
final class TestHistory {
    static let shared = TestHistory()
    private init() { entries = Store.decode([TestHistoryEntry].self, StorageKey.testHistory) ?? [] }

    /// Newest first.
    private(set) var entries: [TestHistoryEntry]

    var preview: [TestHistoryEntry] { Array(entries.prefix(QuizRules.historyPreviewCount)) }

    func add(_ entry: TestHistoryEntry) {
        entries.insert(entry, at: 0)
        if entries.count > QuizRules.maxHistoryEntries {
            entries = Array(entries.prefix(QuizRules.maxHistoryEntries))
        }
        Store.encode(entries, StorageKey.testHistory)
    }
}
