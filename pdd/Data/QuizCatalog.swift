//
//  QuizCatalog.swift
//  pdd
//
//  Deterministic Card → 2 Module → Task hierarchy (8 cards / 72 tasks).
//

import Foundation

enum Difficulty: String, CaseIterable {
    case easy, medium, advanced

    var questionCount: Int {
        switch self {
        case .easy: QuizRules.easyQuestions
        case .medium: QuizRules.mediumQuestions
        case .advanced: QuizRules.advancedQuestions
        }
    }
    var timeLimit: Int { questionCount * QuizRules.secondsPerQuestion }
    var title: String {
        switch self {
        case .easy: "Лёгкий уровень"
        case .medium: "Средний уровень"
        case .advanced: "Продвинутый уровень"
        }
    }
}

struct QuizTask: Identifiable, Hashable {
    let id: String            // {cardId}_m{moduleNo}_t{taskNo}
    let cardId: String
    let moduleNo: Int
    let taskNo: Int
    let isControl: Bool
    let difficulty: Difficulty
    var title: String { "Задание \(taskNo)" }
}

struct QuizModule: Identifiable, Hashable {
    let id: String            // {cardId}_m{moduleNo}
    let moduleNo: Int
    let tasks: [QuizTask]
}

struct QuizCard: Identifiable, Hashable {
    let id: String            // e.g. easy_1
    let difficulty: Difficulty
    let indexInLevel: Int
    let modules: [QuizModule]

    var title: String { "\(difficulty.title) · Карточка \(indexInLevel)" }
    var totalTasks: Int { modules.reduce(0) { $0 + $1.tasks.count } }
    var imageName: String { "pdd_go_card" }
}

enum QuizCatalog {
    /// Card layout per level: easy×3, medium×2, advanced×3 (8 total).
    private static let layout: [(Difficulty, Int)] = [
        (.easy, 3), (.medium, 2), (.advanced, 3)
    ]

    static let cards: [QuizCard] = {
        var result: [QuizCard] = []
        for (difficulty, count) in layout {
            for i in 1...count {
                let cardId = "\(difficulty.rawValue)_\(i)"
                let modules = [
                    makeModule(cardId: cardId, moduleNo: 1, taskCount: 5, difficulty: difficulty, controlTask: 5),
                    makeModule(cardId: cardId, moduleNo: 2, taskCount: 4, difficulty: difficulty, controlTask: nil),
                ]
                result.append(QuizCard(id: cardId, difficulty: difficulty, indexInLevel: i, modules: modules))
            }
        }
        return result
    }()

    private static func makeModule(cardId: String, moduleNo: Int, taskCount: Int,
                                    difficulty: Difficulty, controlTask: Int?) -> QuizModule {
        let tasks = (1...taskCount).map { t in
            QuizTask(
                id: "\(cardId)_m\(moduleNo)_t\(t)",
                cardId: cardId, moduleNo: moduleNo, taskNo: t,
                isControl: controlTask == t,
                difficulty: difficulty
            )
        }
        return QuizModule(id: "\(cardId)_m\(moduleNo)", moduleNo: moduleNo, tasks: tasks)
    }

    static func cards(for difficulty: Difficulty) -> [QuizCard] {
        cards.filter { $0.difficulty == difficulty }
    }
    static func card(id: String) -> QuizCard? { cards.first { $0.id == id } }
    static func task(id: String) -> QuizTask? {
        cards.flatMap { $0.modules }.flatMap { $0.tasks }.first { $0.id == id }
    }

    /// Questions for a catalog task (deterministic window).
    static func questions(for task: QuizTask) -> [PddQuestion] {
        QuestionBank.shared.deterministicSet(taskId: task.id, count: task.difficulty.questionCount)
    }
}
