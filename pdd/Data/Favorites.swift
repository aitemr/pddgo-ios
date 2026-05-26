//
//  Favorites.swift
//  pdd
//

import Foundation
import Observation

@Observable
final class Favorites {
    static let shared = Favorites()
    private init() {
        questionIds = Store.decode([Int].self, StorageKey.favoriteQuestions) ?? []
        lessonPractice = Store.decode([String].self, StorageKey.favoriteLessonPractice) ?? []
    }

    private(set) var questionIds: [Int]
    private(set) var lessonPractice: [String]

    func contains(_ id: Int) -> Bool { questionIds.contains(id) }

    func toggle(id: Int) {
        if let idx = questionIds.firstIndex(of: id) {
            questionIds.remove(at: idx)
        } else {
            questionIds.append(id)
        }
        Store.encode(questionIds, StorageKey.favoriteQuestions)
    }

    func toggleLesson(_ key: String) {
        if let idx = lessonPractice.firstIndex(of: key) {
            lessonPractice.remove(at: idx)
        } else {
            lessonPractice.append(key)
        }
        Store.encode(lessonPractice, StorageKey.favoriteLessonPractice)
    }

    var questions: [PddQuestion] { QuestionBank.shared.questions(ids: questionIds) }
}
