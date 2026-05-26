//
//  ProgressStore.swift
//  pdd
//

import Foundation
import Observation

struct TaskProgress {
    let completed: Bool
    let score: Int
    let total: Int
    var accuracy: Double { total == 0 ? 0 : Double(score) / Double(total) }
}

@Observable
final class ProgressStore {
    static let shared = ProgressStore()
    private init() {
        correctTotal = Store.int(StorageKey.correctTotal)
        answeredTotal = Store.int(StorageKey.answeredTotal)
    }

    private(set) var correctTotal: Int
    private(set) var answeredTotal: Int
    /// Bumped on writes so observing views recompute task progress.
    private(set) var revision = 0

    func progress(taskId: String) -> TaskProgress {
        TaskProgress(
            completed: Store.bool(StorageKey.taskDone(taskId)),
            score: Store.int(StorageKey.taskScore(taskId)),
            total: Store.int(StorageKey.taskTotal(taskId))
        )
    }

    /// Records a single answer toward the global counters.
    func recordQuestionAnswer(isCorrect: Bool) {
        answeredTotal += 1
        if isCorrect { correctTotal += 1 }
        Store.set(answeredTotal, StorageKey.answeredTotal)
        Store.set(correctTotal, StorageKey.correctTotal)
    }

    /// Marks a catalog task completed with its score.
    func completeTask(_ taskId: String, score: Int, total: Int) {
        Store.set(true, StorageKey.taskDone(taskId))
        Store.set(score, StorageKey.taskScore(taskId))
        Store.set(total, StorageKey.taskTotal(taskId))
        revision += 1
    }

    var overallAccuracy: Double {
        answeredTotal == 0 ? 0 : Double(correctTotal) / Double(answeredTotal)
    }
}
