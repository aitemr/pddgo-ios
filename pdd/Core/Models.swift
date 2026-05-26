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
    let correct: Bool

    func localized(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return answerKZ.isEmpty ? answer : answerKZ
        default:  return answer.isEmpty ? answerKZ : answer   // en falls back to ru
        }
    }
}

struct PddQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let question: String       // ru
    let questionKZ: String      // kk
    let answerDesc: String      // ru
    let answerDescKZ: String    // kk
    let animationType: PddAnimationType
    let animationQuestionUrl: String
    let answers: [PddAnswer]

    enum CodingKeys: String, CodingKey {
        case id, question, questionKZ, answerDesc, answerDescKZ
        case animationType, animationQuestionUrl, answers
    }

    var correctIndex: Int { answers.firstIndex { $0.correct } ?? -1 }

    func localizedQuestion(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return questionKZ.isEmpty ? question : questionKZ
        default:  return question.isEmpty ? questionKZ : question
        }
    }

    func localizedExplanation(_ lang: AppLanguage) -> String {
        switch lang {
        case .kk: return answerDescKZ.isEmpty ? answerDesc : answerDescKZ
        default:  return answerDesc.isEmpty ? answerDescKZ : answerDesc
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
