//
//  QuizViewModel.swift
//  pdd
//
//  Quiz state machine (spec §5).
//

import Foundation
import Observation
import UIKit

@Observable
final class QuizViewModel {
    let config: QuizConfig
    let questions: [PddQuestion]

    var currentIndex = 0
    var selectedOptionIndex: Int?
    var isAnswerSubmitted = false

    private(set) var recordedUserChoices: [Int?]
    private(set) var submittedPerQuestion: [Bool]
    private(set) var correctAnswers = 0

    // Timer
    var remainingSeconds: Int
    private(set) var quizTimedOut = false
    private var timer: Timer?

    var onFinish: ((QuizResult) -> Void)?

    init(config: QuizConfig) {
        self.config = config
        self.questions = config.questions
        let n = questions.count
        recordedUserChoices = config.replayChoices ?? Array(repeating: nil, count: n)
        submittedPerQuestion = Array(repeating: config.isReplay, count: n)
        remainingSeconds = config.timeLimit ?? 0
        if config.isReplay {
            // Prefill correctAnswers for display continuity.
            correctAnswers = zip(questions, recordedUserChoices).filter { $0.0.correctIndex == $0.1 }.count
        }
        restoreCurrentState()
    }

    // MARK: Derived

    var current: PddQuestion { questions[currentIndex] }
    var total: Int { questions.count }
    var isLastQuestion: Bool { currentIndex == total - 1 }
    var lang: AppLanguage { Session.shared.language }
    var isReplay: Bool { config.isReplay }

    var canFavorite: Bool { isAnswerSubmitted && !isReplay }
    /// Akzhol button is active only when the submitted answer was wrong.
    var canAskAkzhol: Bool {
        isAnswerSubmitted && !isReplay && selectedOptionIndex != current.correctIndex
    }

    // MARK: Lifecycle

    func start() {
        guard config.timeLimit != nil, !isReplay, timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            quizTimedOut = true
            finish()
            return
        }
        remainingSeconds -= 1
    }

    private func stopTimer() { timer?.invalidate(); timer = nil }

    // MARK: Answering

    func selectOption(_ i: Int) {
        guard !isAnswerSubmitted, !isReplay else { return }
        selectedOptionIndex = i
    }

    func submitAnswer() {
        guard !isAnswerSubmitted, !isReplay, let choice = selectedOptionIndex else { return }
        isAnswerSubmitted = true
        submittedPerQuestion[currentIndex] = true
        recordedUserChoices[currentIndex] = choice

        let isCorrect = choice == current.correctIndex
        if isCorrect {
            correctAnswers += 1
            Haptics.notify(.success)
        } else {
            MistakesBank.shared.addWrongIds([current.id])
            Haptics.notify(.error)
        }
        ProgressStore.shared.recordQuestionAnswer(isCorrect: isCorrect)
    }

    // MARK: Navigation

    func goNext() {
        if isLastQuestion { finish(); return }
        currentIndex += 1
        restoreCurrentState()
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        restoreCurrentState()
    }

    private func restoreCurrentState() {
        selectedOptionIndex = recordedUserChoices[currentIndex]
        isAnswerSubmitted = submittedPerQuestion[currentIndex]
    }

    func toggleFavorite() {
        guard canFavorite else { return }
        Favorites.shared.toggle(id: current.id)
    }
    var isCurrentFavorite: Bool { Favorites.shared.contains(current.id) }

    // MARK: Finish

    func finish() {
        stopTimer()
        let passed = config.isTrialExam ? correctAnswers >= QuizRules.trialPassThreshold : true
        let type: ResultType = config.isTrialExam ? (passed ? .success : .failure) : .completion
        let elapsed = config.timeLimit.map { $0 - remainingSeconds }

        // Persist (skipped entirely in replay).
        if !isReplay {
            if config.isLessonPractice {
                UsageLimits.shared.recordLessonPracticeCompleted(hash: config.moduleId)
            } else if config.isTrialExam {
                let entry = TestHistoryEntry(
                    quizModuleId: config.moduleId,
                    score: correctAnswers, total: total, passed: passed,
                    completedAtMillis: Int(Date().timeIntervalSince1970 * 1000),
                    questionIds: questions.map(\.id),
                    userChoices: recordedUserChoices
                )
                TestHistory.shared.add(entry)
                if config.moduleId == TrialExam.individual {
                    let seen = questions.map(\.id)
                    let stillWrong = zip(questions, recordedUserChoices)
                        .compactMap { q, c in c != q.correctIndex ? q.id : nil }
                    MistakesBank.shared.applySessionResult(seen: seen, stillWrong: stillWrong)
                }
            } else {
                ProgressStore.shared.completeTask(config.moduleId, score: correctAnswers, total: total)
                UsageLimits.shared.recordQuizCompleted(moduleId: config.moduleId)
            }
        }

        onFinish?(QuizResult(
            type: type, score: correctAnswers, total: total, passed: passed,
            timedOut: quizTimedOut, elapsedSeconds: elapsed, timeLimit: config.timeLimit,
            questions: questions, userChoices: recordedUserChoices, isTrialExam: config.isTrialExam
        ))
    }
}
