//
//  OnDeviceAkzhol.swift
//  pdd
//
//  Apple Intelligence (on-device) backend for Akzhol via the Foundation
//  Models framework. Used when the device supports Apple Intelligence and
//  no images are attached. Falls back transparently to the cloud Gemini
//  client (AkzholService) when unavailable.
//
//  Requires iOS 26+ and an Apple Intelligence-eligible device.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
enum OnDeviceAkzhol {
    /// True when the system model is fully ready for prompting.
    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        default:         return false
        }
    }

    /// Replies as Akzhol using the on-device model. Throws when the model
    /// is unavailable or generation fails — the caller should fall back to
    /// the cloud provider.
    static func reply(history: [ChatMessage], lang: AppLanguage) async throws -> String {
        let instructions = persona(lang: lang)
        let session = LanguageModelSession(instructions: instructions)
        let prompt = renderPrompt(history: history)
        let response = try await session.respond(to: prompt)
        return response.content
    }

    // MARK: - Prompt assembly

    private static func persona(lang: AppLanguage) -> String {
        let langName = lang == .kk ? "казахском" : lang == .en ? "английском" : "русском"
        return """
        Ты — Акжол, опытный инспектор и эксперт по ПДД Республики Казахстан. \
        Говоришь спокойно, уверенно и прямо, как профессионал. Короткие чёткие \
        предложения, без AI-клише. По умолчанию 2–4 предложения. Движение \
        правостороннее. Отвечай на \(langName) языке. Отклоняй вопросы не по теме ПДД и вождения.
        """
    }

    /// Serializes the multi-turn history into a single prompt that ends
    /// with an empty assistant turn so the model continues with the reply.
    private static func renderPrompt(history: [ChatMessage]) -> String {
        var lines: [String] = []
        for m in history where !m.text.isEmpty {
            var text = m.text
            if let ctx = m.quizContextForApi, !ctx.isEmpty { text += "\n\n" + ctx }
            lines.append((m.isUser ? "User: " : "Akzhol: ") + text)
        }
        lines.append("Akzhol:")
        return lines.joined(separator: "\n\n")
    }
}
#else
@available(iOS 26.0, *)
enum OnDeviceAkzhol {
    static var isAvailable: Bool { false }
    static func reply(history: [ChatMessage], lang: AppLanguage) async throws -> String {
        throw NSError(domain: "OnDeviceAkzhol", code: -1, userInfo: nil)
    }
}
#endif
