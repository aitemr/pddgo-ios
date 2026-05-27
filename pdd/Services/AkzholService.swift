//
//  AkzholService.swift
//  pdd
//
//  Gemini-backed AI assistant. Uses the REST API directly via URLSession, so
//  no SDK dependency is needed — only an API key in Info.plist (GEMINI_API_KEY).
//  Without a key the client returns a graceful offline message so the UI runs.
//

import Foundation
import UIKit

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isUser: Bool
    var imageDatas: [Data] = []
    var quizContextForApi: String? = nil
    var isTyping: Bool = false

    static func == (l: ChatMessage, r: ChatMessage) -> Bool { l.id == r.id }
}

final class AkzholService {
    static let shared = AkzholService()
    private init() {}

    private let models = ["gemini-2.5-flash", "gemini-2.0-flash", "gemini-1.5-flash"]
    private let maxHistory = 24

    private var apiKey: String? {
        let k = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
        return (k?.isEmpty == false) ? k : nil
    }

    var isConfigured: Bool { apiKey != nil }

    /// Persona system instruction (spec §11).
    private func persona(lang: AppLanguage) -> String {
        let langName = lang == .kk ? "казахском" : lang == .en ? "английском" : "русском"
        return """
        Ты — Акжол, опытный инспектор и эксперт по ПДД Республики Казахстан. \
        Говоришь спокойно, уверенно и прямо, как профессионал. Короткие чёткие \
        предложения, без AI-клише. По умолчанию 2–4 предложения. Движение \
        правостороннее. Отвечай на \(langName) языке. Отклоняй вопросы не по теме ПДД и вождения.
        """
    }

    /// Sends the conversation and returns the assistant reply text.
    /// Prefers Apple Intelligence (on-device) when available and there are
    /// no image attachments; otherwise falls back to the Gemini cloud API.
    func reply(history: [ChatMessage], lang: AppLanguage) async throws -> String {
        let trimmed = Array(history.suffix(maxHistory))
        let hasImages = trimmed.contains { !$0.imageDatas.isEmpty }

        // Apple Intelligence path — text-only, no key required.
        if !hasImages, #available(iOS 26.0, *), OnDeviceAkzhol.isAvailable {
            do {
                return try await OnDeviceAkzhol.reply(history: trimmed, lang: lang)
            } catch {
                // Fall through to cloud on any on-device failure.
            }
        }

        // Cloud path (Gemini).
        guard let key = apiKey else {
            return offlineFallback(lang: lang)
        }
        var lastError: Error?
        for model in models {
            do {
                return try await request(model: model, key: key, history: trimmed, lang: lang)
            } catch let e as AkzholError where e.isRetryable {
                lastError = e
                continue   // try fallback model on 429/503
            }
        }
        throw lastError ?? AkzholError.server(0)
    }

    // MARK: - Networking

    private func request(model: String, key: String,
                         history: [ChatMessage], lang: AppLanguage) async throws -> String {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(key)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body(history: history, lang: lang))

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard code == 200 else { throw AkzholError.server(code) }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw AkzholError.decode
        }
        let text = parts.compactMap { $0["text"] as? String }.joined()
        return text.isEmpty ? offlineFallback(lang: lang) : text
    }

    private func body(history: [ChatMessage], lang: AppLanguage) -> [String: Any] {
        var contents: [[String: Any]] = []
        for m in history where !m.text.isEmpty || !m.imageDatas.isEmpty {
            var parts: [[String: Any]] = []
            var text = m.text
            if let ctx = m.quizContextForApi, !ctx.isEmpty { text += "\n\n" + ctx }
            if !text.isEmpty { parts.append(["text": text]) }
            for data in m.imageDatas {
                parts.append(["inline_data": ["mime_type": "image/jpeg",
                                              "data": data.base64EncodedString()]])
            }
            contents.append(["role": m.isUser ? "user" : "model", "parts": parts])
        }
        return [
            "system_instruction": ["parts": [["text": persona(lang: lang)]]],
            "contents": contents,
            "generationConfig": [
                "temperature": 0.45,
                "topP": 0.95,
                "maxOutputTokens": 640,
            ],
        ]
    }

    private func offlineFallback(lang: AppLanguage) -> String {
        switch lang {
        case .kk: return "Akzhol уақытша қолжетімсіз. GEMINI_API_KEY кілтін Info.plist ішіне қосыңыз."
        case .en: return "Akzhol is offline. Add GEMINI_API_KEY to Info.plist to enable AI answers."
        default:  return "Акжол сейчас офлайн. Чтобы включить ИИ-ответы, добавьте GEMINI_API_KEY в Info.plist."
        }
    }
}

enum AkzholError: Error {
    case server(Int)
    case decode
    var isRetryable: Bool {
        if case let .server(code) = self { return code == 429 || code == 503 }
        return false
    }
}

// MARK: - Mistakes → AI context (spec §6)

enum AIContext {
    /// Russian markdown listing only the incorrectly answered questions.
    static func buildMistakesWorkContextRu(questions: [PddQuestion], userChoices: [Int?]) -> String {
        var lines = ["Разбор ошибок. Ниже список вопросов, на которые пользователь ответил неверно. Объясни кратко по каждому.\n"]
        var n = 0
        for (i, q) in questions.enumerated() {
            guard i < userChoices.count, let choice = userChoices[i], choice != q.correctIndex else { continue }
            n += 1
            let chosen = (choice >= 0 && choice < q.answers.count) ? q.answers[choice].answer : "—"
            let correct = q.correctIndex >= 0 ? q.answers[q.correctIndex].answer : "—"
            lines.append("\(n). \(q.question)")
            lines.append("   Ответ пользователя: \(chosen)")
            lines.append("   Верный ответ: \(correct)")
            if !q.answerDesc.isEmpty { lines.append("   Пояснение: \(q.answerDesc)") }
            lines.append("")
        }
        let text = lines.joined(separator: "\n")
        return String(text.prefix(QuizRules.aiContextMaxChars))
    }
}
