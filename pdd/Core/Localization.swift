//
//  Localization.swift
//  pdd
//
//  Runtime localization for UI strings. The selected language lives in
//  `Session.shared.language` so it can switch without an app relaunch.
//
//  Usage in Strings.swift:
//      static var navTests: String { Localizer.pick(ru: "Тесты", kk: "Тесттер", en: "Tests") }
//
//  Russian remains the source-of-truth; missing translations fall back to ru.
//  Question content (kk/en) is still served from pdd_questions.json via
//  PddQuestion.localizedQuestion(_:) — this helper is for UI chrome only.
//

import Foundation

enum Localizer {
    static func pick(ru: String, kk: String? = nil, en: String? = nil) -> String {
        switch Session.shared.language {
        case .ru: return ru
        case .kk: return (kk?.isEmpty == false) ? kk! : ru
        case .en: return (en?.isEmpty == false) ? en! : ru
        }
    }
}
