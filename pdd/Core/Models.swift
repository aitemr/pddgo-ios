//
//  Models.swift
//  pdd
//
//  Question-bank domain model (matches assets/data/pdd_questions.json).
//

import Foundation

enum PddAnimationType: String, Codable {
    case noPicture = "NO_PICTURE"
    case medical = "MEDICAL"
    case withoutAnswer = "WITHOUT_ANSWER"
    case unknown

    init(from decoder: Decoder) throws {
        let raw = (try? decoder.singleValueContainer().decode(String.self)) ?? ""
        self = PddAnimationType(rawValue: raw) ?? .unknown
    }
}

struct PddAnswer: Codable, Identifiable, Hashable {
    let id: Int
    let answer: String       // ru
    let answerKZ: String     // kk
    let answerENG: String    // en (optional in JSON; defaults to "")
    let correct: Bool

    enum CodingKeys: String, CodingKey { case id, answer, answerKZ, answerENG, correct }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        answer = try c.decodeIfPresent(String.self, forKey: .answer) ?? ""
        answerKZ = try c.decodeIfPresent(String.self, forKey: .answerKZ) ?? ""
        answerENG = try c.decodeIfPresent(String.self, forKey: .answerENG) ?? ""
        correct = try c.decode(Bool.self, forKey: .correct)
    }

    func localized(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return answerKZ.isEmpty ? answer : answerKZ
        case .en: return answerENG.isEmpty ? answer : answerENG
        case .ru: return answer.isEmpty ? answerKZ : answer
        }
    }
}

struct PddQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let question: String        // ru
    let questionKZ: String      // kk
    let questionENG: String     // en (optional in JSON; defaults to "")
    let answerDesc: String      // ru
    let answerDescKZ: String    // kk
    let answerDescENG: String   // en (optional in JSON; defaults to "")
    let animationType: PddAnimationType
    let animationQuestionUrl: String
    let answers: [PddAnswer]

    enum CodingKeys: String, CodingKey {
        case id, question, questionKZ, questionENG
        case answerDesc, answerDescKZ, answerDescENG
        case animationType, animationQuestionUrl, answers
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        question = try c.decodeIfPresent(String.self, forKey: .question) ?? ""
        questionKZ = try c.decodeIfPresent(String.self, forKey: .questionKZ) ?? ""
        questionENG = try c.decodeIfPresent(String.self, forKey: .questionENG) ?? ""
        answerDesc = try c.decodeIfPresent(String.self, forKey: .answerDesc) ?? ""
        answerDescKZ = try c.decodeIfPresent(String.self, forKey: .answerDescKZ) ?? ""
        answerDescENG = try c.decodeIfPresent(String.self, forKey: .answerDescENG) ?? ""
        animationType = try c.decodeIfPresent(PddAnimationType.self, forKey: .animationType) ?? .unknown
        animationQuestionUrl = try c.decodeIfPresent(String.self, forKey: .animationQuestionUrl) ?? ""
        answers = try c.decodeIfPresent([PddAnswer].self, forKey: .answers) ?? []
    }

    var correctIndex: Int { answers.firstIndex { $0.correct } ?? -1 }

    func localizedQuestion(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return questionKZ.isEmpty ? question : questionKZ
        case .en: return questionENG.isEmpty ? question : questionENG
        case .ru: return question.isEmpty ? questionKZ : question
        }
    }

    func localizedExplanation(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return answerDescKZ.isEmpty ? answerDesc : answerDescKZ
        case .en: return answerDescENG.isEmpty ? answerDesc : answerDescENG
        case .ru: return answerDesc.isEmpty ? answerDescKZ : answerDesc
        }
    }

    /// A playable mp4 url for video questions (empty / placeholder urls ignored).
    var videoURL: URL? {
        guard !animationQuestionUrl.isEmpty,
              !animationQuestionUrl.contains("no_picture"),
              let u = URL(string: animationQuestionUrl) else { return nil }
        return u
    }
}

// MARK: - Language

enum AppLanguage: String, CaseIterable, Codable {
    case ru, kk, en

    var displayName: String {
        switch self {
        case .ru: "Русский"
        case .kk: "Қазақша"
        case .en: "English"
        }
    }
    var flag: String {
        switch self {
        case .ru: "🇷🇺"
        case .kk: "🇰🇿"
        case .en: "🇬🇧"
        }
    }
}
