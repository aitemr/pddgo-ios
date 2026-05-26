//
//  QuestionBank.swift
//  pdd
//
//  Loads the bundled 848-question bank and performs deterministic,
//  reproducible windowed selection by task id (FNV-1a).
//

import Foundation

final class QuestionBank {
    static let shared = QuestionBank()

    /// All questions, sorted ascending by id (stable order for windowing).
    let all: [PddQuestion]
    private let byId: [Int: PddQuestion]

    private init() {
        let loaded = Bundle.main.decodeJSON([PddQuestion].self, from: "pdd_questions.json")
        all = loaded.sorted { $0.id < $1.id }
        byId = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }

    func question(id: Int) -> PddQuestion? { byId[id] }
    func questions(ids: [Int]) -> [PddQuestion] { ids.compactMap { byId[$0] } }

    /// Deterministic contiguous window of `count` questions chosen from a stable
    /// offset derived from `taskId`. The same id always yields the same set.
    func deterministicSet(taskId: String, count: Int) -> [PddQuestion] {
        let n = min(count, all.count)
        guard all.count > n else { return all }
        let span = all.count - n
        let offset = Int(fnv1a32(taskId) % UInt32(span))
        return Array(all[offset..<offset + n])
    }
}
