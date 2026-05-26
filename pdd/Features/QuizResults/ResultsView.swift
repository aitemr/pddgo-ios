//
//  ResultsView.swift
//  pdd
//
//  Faithful port of results_screen.dart (_buildResultView).
//

import SwiftUI

struct ResultsView: View {
    let result: QuizResult
    var onPrimary: () -> Void
    var onClose: () -> Void

    @State private var mistakesChat: ChatViewModel?
    @State private var showPaywall = false

    private var isSuccess: Bool { result.type == .success }

    var body: some View {
        VStack(spacing: 0) {
            imageBlock
            Spacer(minLength: 0)
            VStack(spacing: 16) {
                if result.hasMistakes {
                    secondaryButton
                }
                mainButton
            }
            .padding(.horizontal, 30).padding(.bottom, 24)
        }
        .background(.white)
        .ignoresSafeArea(edges: .top)
        .sheet(item: $mistakesChat) { vm in
            AskAkzholSheet(vm: vm).presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    private var imageBlock: some View {
        ZStack(alignment: .top) {
            Image(isSuccess ? "quizdoneCar" : "quizFail")
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 540)
                .clipped()
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 48, bottomTrailingRadius: 48))

            VStack(spacing: 0) {
                Image(isSuccess ? "straightSign" : "minusSign")
                    .resizable().scaledToFit().frame(height: 70).padding(.top, 20)
                Text(L.resultScore(result.score, result.total))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(isSuccess ? Color(hex: "#0047FF") : Color(hex: "#E53935"))
                    .padding(.top, 16)
                Text(isSuccess ? L.resultSuccessSubtitle : L.resultFailSubtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.87))
                    .multilineTextAlignment(.center).lineSpacing(4).padding(.top, 8)
                if let used = result.elapsedSeconds, let limit = result.timeLimit {
                    Text("\(formatMMSS(used)) / \(formatMMSS(limit))")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.54)).padding(.top, 14)
                    if result.timedOut {
                        Text("Время вышло").font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.black.opacity(0.45)).padding(.top, 6)
                    }
                }
            }
            .padding(.top, 56)

            if !isSuccess {
                VStack {
                    Spacer()
                    Text(L.resultAkzholBubble)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.brandBlue)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.08), radius: 15, y: 5)
                        .padding(.bottom, 20)
                }
                .frame(height: 540)
            }

            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.87))
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.92), in: Circle())
                }.buttonStyle(.plain)
            }
            .padding(.top, 56).padding(.trailing, 12)
        }
    }

    private var secondaryButton: some View {
        Button { openMistakes() } label: {
            HStack(spacing: 10) {
                Image("akzhol").resizable().scaledToFit()
                    .frame(width: 24, height: 24).clipShape(Circle()).background(AppColor.brandBlue, in: Circle())
                Text(L.workOnMistakes)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.brandBlue).multilineTextAlignment(.center)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16).frame(maxWidth: .infinity).frame(height: 72)
            .overlay(RoundedRectangle(cornerRadius: 50).stroke(AppColor.brandBlue, lineWidth: 1))
        }.buttonStyle(.plain)
    }

    private var mainButton: some View {
        Button { Haptics.impact(); onPrimary() } label: {
            HStack(spacing: 8) {
                Text(isSuccess ? L.resultNextTest : L.resultTryAgain)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 72)
            .background(AppColor.brandBlue, in: Capsule())
        }.buttonStyle(.plain)
    }

    private func openMistakes() {
        if !UsageLimits.shared.canUseAkzhol { showPaywall = true; return }
        let chat = ChatViewModel()
        chat.onLimitReached = { showPaywall = true }
        chat.pendingContext = AIContext.buildMistakesWorkContextRu(
            questions: result.questions, userChoices: result.userChoices)
        chat.input = "Разбери мои ошибки и объясни верные ответы"
        mistakesChat = chat
    }
}
