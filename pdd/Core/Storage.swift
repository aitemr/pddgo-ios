//
//  Storage.swift
//  pdd
//
//  UserDefaults-backed storage with the spec's exact keys (§7, §13, §17).
//

import Foundation

enum StorageKey {
    // Progress
    static func taskDone(_ id: String) -> String { "task_done_\(id)" }
    static func taskScore(_ id: String) -> String { "task_score_\(id)" }
    static func taskTotal(_ id: String) -> String { "task_total_\(id)" }
    static let correctTotal = "progress_correct_answers_total_v1"
    static let answeredTotal = "progress_answered_questions_total_v1"

    // History / mistakes / favorites
    static let testHistory = "test_history_entries_v1"
    static let mistakesBank = "mistakes_bank_question_ids_v1"
    static let favoriteQuestions = "pdd_favorite_question_ids"
    static let favoriteLessonPractice = "pdd_favorite_lesson_practice"

    // Usage limits
    static let akzholTurnCount = "akzholTurnCount"
    static func completedQuizId(_ moduleId: String) -> String { "completedQuizIds/\(moduleId)" }
    static func completedLessonPractice(_ hash: String) -> String { "completedLessonPractice/lp_\(hash)" }

    // Settings / session
    static let lang = "lang"
    static let notificationsEnabled = "notificationsEnabled"
    static let hapticsEnabled = "hapticsEnabled"
    static let animationsEnabled = "animationsEnabled"
    static let funnelCompleted = "funnelCompleted"
    static let isLoggedIn = "isLoggedIn"
    static let session = "session_user_info_v1"
}

/// Thin typed wrapper over UserDefaults.
enum Store {
    private static let d = UserDefaults.standard

    static func bool(_ k: String) -> Bool { d.bool(forKey: k) }
    static func int(_ k: String) -> Int { d.integer(forKey: k) }
    static func string(_ k: String) -> String? { d.string(forKey: k) }
    static func set(_ v: Bool, _ k: String) { d.set(v, forKey: k) }
    static func set(_ v: Int, _ k: String) { d.set(v, forKey: k) }
    static func set(_ v: String, _ k: String) { d.set(v, forKey: k) }
    static func remove(_ k: String) { d.removeObject(forKey: k) }

    static func decode<T: Decodable>(_ type: T.Type, _ k: String) -> T? {
        guard let data = d.data(forKey: k) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    static func encode<T: Encodable>(_ v: T, _ k: String) {
        if let data = try? JSONEncoder().encode(v) { d.set(data, forKey: k) }
    }
}
