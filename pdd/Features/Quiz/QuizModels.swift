//
//  QuizModels.swift
//  pdd
//
//  Configuration + result types describing a quiz run.
//

import Foundation

struct QuizConfig: Identifiable {
    let id = UUID()
    var questions: [PddQuestion]
    var moduleId: String           // catalog task id, trial id, or lesson id
    var title: String
    var isTrialExam: Bool = false
    var isControl: Bool = false
    var difficulty: Difficulty? = nil
    var timeLimit: Int? = nil      // seconds; nil = no timer
    var isLessonPractice: Bool = false
    /// Non-nil → replay (view-only): prefilled choices, no submit/AI/favorite,
    /// no progress or history recorded.
    var replayChoices: [Int?]? = nil

    var isReplay: Bool { replayChoices != nil }

    static func catalogTask(_ task: QuizTask) -> QuizConfig {
        QuizConfig(
            questions: QuizCatalog.questions(for: task),
            moduleId: task.id,
            title: task.title,
            difficulty: task.difficulty,
            timeLimit: task.difficulty.timeLimit
        )
    }

    static func trialStandard() -> QuizConfig {
        QuizConfig(
            questions: QuestionBank.shared.deterministicSet(taskId: TrialExam.standard, count: QuizRules.trialQuestionCount),
            moduleId: TrialExam.standard,
            title: "Пробное тестирование",
            isTrialExam: true,
            timeLimit: QuizRules.trialQuestionCount * QuizRules.secondsPerQuestion
        )
    }

    static func trialIndividual() -> QuizConfig {
        QuizConfig(
            questions: MistakesBank.shared.loadQuestions(),
            moduleId: TrialExam.individual,
            title: "Индивидуальное тестирование",
            isTrialExam: true,
            timeLimit: QuizRules.trialQuestionCount * QuizRules.secondsPerQuestion
        )
    }

    static func lessonPractice(id: String, title: String, count: Int = 10) -> QuizConfig {
        QuizConfig(
            questions: QuestionBank.shared.deterministicSet(taskId: "lp_\(id)", count: count),
            moduleId: id,
            title: title,
            isLessonPractice: true
        )
    }

    static func replay(_ entry: TestHistoryEntry) -> QuizConfig {
        QuizConfig(
            questions: QuestionBank.shared.questions(ids: entry.questionIds),
            moduleId: entry.quizModuleId,
            title: "Просмотр результата",
            isTrialExam: true,
            replayChoices: entry.userChoices
        )
    }
}

enum ResultType { case success, failure, completion }

struct QuizResult {
    let type: ResultType
    let score: Int
    let total: Int
    let passed: Bool
    let timedOut: Bool
    let elapsedSeconds: Int?
    let timeLimit: Int?
    let questions: [PddQuestion]
    let userChoices: [Int?]
    let isTrialExam: Bool

    var hasMistakes: Bool {
        zip(questions, userChoices).contains { q, c in c != q.correctIndex }
    }
    var wrongQuestionIds: [Int] {
        zip(questions, userChoices).compactMap { q, c in c != q.correctIndex ? q.id : nil }
    }
}
