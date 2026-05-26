//
//  UsefulMaterialDetailView.swift
//  pdd
//
//  Collapsing hero + Gemini-loaded markdown (spec §9), with loading/retry.
//

import SwiftUI

struct UsefulMaterialDetailView: View {
    let material: UsefulMaterial

    enum LoadState { case loading, loaded(String), failed }
    @State private var state: LoadState = .loading

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Image(material.image).resizable().scaledToFill()
                    .frame(height: 220).frame(maxWidth: .infinity).clipped()
                Text(material.title)
                    .font(.app(26, .bold)).foregroundStyle(AppColor.textBlack)
                    .padding(.horizontal, AppLayout.homeMargin).padding(.top, 16)

                Group {
                    switch state {
                    case .loading:
                        VStack(spacing: 12) {
                            ProgressView().tint(AppColor.brandBlue)
                            Text("Готовим материал…").font(.app(14)).foregroundStyle(AppColor.greyText)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 60)
                    case .failed:
                        VStack(spacing: 14) {
                            Text("Не удалось загрузить материал").font(.app(16)).foregroundStyle(AppColor.greyText)
                            SecondaryButton(title: "Повторить") { load() }.frame(width: 200)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 60)
                    case .loaded(let text):
                        MarkdownText(text)
                            .padding(.horizontal, AppLayout.homeMargin).padding(.top, 12)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(.white)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .task { load() }
    }

    private func load() {
        state = .loading
        Task { @MainActor in
            do {
                let text = try await AkzholService.shared.reply(
                    history: [ChatMessage(text: material.prompt + "\nОтветь в формате markdown с заголовками.", isUser: true)],
                    lang: Session.shared.language)
                state = .loaded(text)
            } catch {
                state = .failed
            }
        }
    }
}

/// Minimal markdown renderer (H1/H2/paragraph/bullets), spec styles.
struct MarkdownText: View {
    let raw: String
    init(_ raw: String) { self.raw = raw }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                renderLine(line)
            }
        }
    }

    private var lines: [String] { raw.components(separatedBy: "\n") }

    @ViewBuilder private func renderLine(_ line: String) -> some View {
        let t = line.trimmingCharacters(in: .whitespaces)
        if t.isEmpty {
            Color.clear.frame(height: 2)
        } else if t.hasPrefix("# ") {
            Text(t.dropFirst(2)).font(.app(22, .bold)).foregroundStyle(AppColor.brandBlue)
        } else if t.hasPrefix("## ") {
            Text(t.dropFirst(3)).font(.app(18, .bold)).foregroundStyle(AppColor.textBlack)
        } else if t.hasPrefix("- ") || t.hasPrefix("* ") {
            HStack(alignment: .top, spacing: 8) {
                Text("•").foregroundStyle(AppColor.brandBlue)
                Text(inline(String(t.dropFirst(2)))).font(.app(16)).foregroundStyle(AppColor.textBlack)
            }
        } else {
            Text(inline(t)).font(.app(16)).foregroundStyle(AppColor.textBlack).lineSpacing(4)
        }
    }

    private func inline(_ s: String) -> AttributedString {
        (try? AttributedString(markdown: s)) ?? AttributedString(s)
    }
}
