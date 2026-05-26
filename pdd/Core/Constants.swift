//
//  Constants.swift
//  pdd
//
//  Business-rule constants — kept 1:1 with the spec (§19).
//

import Foundation

enum QuizRules {
    static let trialQuestionCount = 40
    static let trialPassThreshold = 32        // 80%
    static let easyQuestions = 20
    static let mediumQuestions = 30
    static let advancedQuestions = 40
    static let secondsPerQuestion = 60
    static let questionBankTotal = 848
    static let maxHistoryEntries = 200
    static let historyPreviewCount = 8
    static let aiContextMaxChars = 24_000
    static let freeAkzholTurns = 3
}

/// Trial-exam module ids.
enum TrialExam {
    static let standard = "trial_exam_kz"
    static let individual = "trial_exam_individual"   // work-on-mistakes
}
