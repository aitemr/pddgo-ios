//
//  MistakesBank.swift
//  pdd
//

import Foundation
import Observation

@Observable
final class MistakesBank {
    static let shared = MistakesBank()
    private init() { ids = Store.decode([Int].self, StorageKey.mistakesBank) ?? [] }

    private(set) var ids: [Int]

    var count: Int { ids.count }
    var isEmpty: Bool { ids.isEmpty }

    func addWrongIds(_ wrong: [Int]) {
        var set = Set(ids)
        set.formUnion(wrong)
        ids = set.sorted()
        persist()
    }

    /// Remove the questions that were seen and corrected, keep the still-wrong ones.
    func applySessionResult(seen: [Int], stillWrong: [Int]) {
        var set = Set(ids)
        set.subtract(seen)
        set.formUnion(stillWrong)
        ids = set.sorted()
        persist()
    }

    /// Up to `count` questions from the bank for the individual trial exam.
    func loadQuestions(count: Int = QuizRules.trialQuestionCount) -> [PddQuestion] {
        Array(QuestionBank.shared.questions(ids: ids).prefix(count))
    }

    private func persist() { Store.encode(ids, StorageKey.mistakesBank) }
}
