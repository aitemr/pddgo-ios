//
//  UsageLimits.swift
//  pdd
//
//  Freemium gating (spec §13). Premium removes all limits.
//

import Foundation
import Observation

@Observable
final class UsageLimits {
    static let shared = UsageLimits()
    private init() { akzholTurns = Store.int(StorageKey.akzholTurnCount) }

    private(set) var akzholTurns: Int

    private var premium: Bool { SubscriptionGate.shared.isPremium }

    // MARK: Akzhol (3 free turns)

    var canUseAkzhol: Bool { premium || akzholTurns < QuizRules.freeAkzholTurns }
    var remainingAkzholTurns: Int { max(0, QuizRules.freeAkzholTurns - akzholTurns) }

    func recordAkzholTurn() {
        guard !premium else { return }
        akzholTurns += 1
        Store.set(akzholTurns, StorageKey.akzholTurnCount)
        // TODO(Firebase RTDB): mirror users/{uid}/usageLimits/akzholTurnCount
    }

    // MARK: Quiz repeat (1 per module)

    func canRepeatQuiz(moduleId: String) -> Bool {
        premium || !Store.bool(StorageKey.completedQuizId(moduleId))
    }
    func recordQuizCompleted(moduleId: String) {
        Store.set(true, StorageKey.completedQuizId(moduleId))
    }

    // MARK: Lesson practice (1 per lesson)

    func canStartLessonPractice(hash: String) -> Bool {
        premium || !Store.bool(StorageKey.completedLessonPractice(hash))
    }
    func recordLessonPracticeCompleted(hash: String) {
        Store.set(true, StorageKey.completedLessonPractice(hash))
    }
}
