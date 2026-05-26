//
//  ResultsView.swift
//  pdd
//
//  Success / failure result screen (Figma + spec §6).
//

import SwiftUI

struct ResultsView: View {
    let result: QuizResult
    var onPrimary: () -> Void
    var onClose: () -> Void

    @State private var mistakesChat: ChatViewModel?
    @State private var showPaywall = false

    private var isFailure: Bool { result.type == .failure }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton(action: onClose)
                Spacer()
            }
            .padding(.horizontal, AppLayout.homeMargin)
            .padding(.top, 8)

            VStack(spacing: 14) {
                sign
                scoreText
                Text(subtitle)
                    .font(.app(16))
                    .foregroundStyle(AppColor.greyText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                if let elapsed = result.elapsedSeconds, let limit = result.timeLimit, result.type == .success {
                    Text("\(formatMMSS(elapsed)) / \(formatMMSS(limit))")
                        .font(.app(14, .medium)).foregroundStyle(AppColor.greyText)
                }
            }
            .padding(.top, 8)

            ZStack(alignment: .bottom) {
                Image(isFailure ? "quizFail" : "quizdoneCar")
                    .resizable().scaledToFit()
                    .frame(maxWidth: .infinity)
                if isFailure {
                    Text("Акжол не готов вас пропустить дальше")
                        .font(.app(15, .medium)).foregroundStyle(.white)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(AppColor.brandBlue.opacity(0.93), in: Capsule())
                        .padding(.bottom, 8)
                }
            }
            .padding(.top, 12)

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                if result.hasMistakes {
                    SecondaryButton(title: "Провести работу над ошибками с Акжол", showsAvatar: true) {
                        openMistakesChat()
                    }
                }
                PrimaryButton(title: primaryTitle, background: isFailure ? AppColor.brandBlue : AppColor.brandBlue) {
                    onPrimary()
                }
            }
            .padding(.horizontal, AppLayout.homeMargin)
            .padding(.bottom, 12)
        }
        .background(.white)
        .sheet(item: $mistakesChat) { vm in
            AskAkzholSheet(vm: vm).presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    // MARK: Pieces

    private var sign: some View {
        ZStack {
            Circle().fill(isFailure ? AppColor.redError : AppColor.brandBlue)
                .frame(width: 64, height: 64)
            if isFailure {
                Capsule().fill(.white).frame(width: 30, height: 8)
            } else {
                Image(systemName: "arrow.up").font(.system(size: 30, weight: .heavy)).foregroundStyle(.white)
            }
        }
    }

    private var scoreText: some View {
        (Text("\(result.score)").font(.app(40, .bold)).foregroundColor(isFailure ? AppColor.redError : AppColor.brandBlue)
         + Text(" из ").font(.app(28, .semibold)).foregroundColor(AppColor.textBlack)
         + Text("\(result.total)").font(.app(40, .bold)).foregroundColor(isFailure ? AppColor.redError : AppColor.brandBlue))
    }

    private var subtitle: String {
        if result.timedOut { return "Время истекло. " + (isFailure ? "Этого балла недостаточно для успешного прохождения теста" : "") }
        switch result.type {
        case .success: return "Отлично! Продолжай тренироваться, чтобы на реальной сдаче не было ни единого сомнения"
        case .failure: return "Этого балла недостаточно для успешного прохождения теста"
        case .completion: return "Задание пройдено. Так держать!"
        }
    }

    private var primaryTitle: String {
        switch result.type {
        case .success: "Продолжить"
        case .failure: "Попробовать ещё"
        case .completion: "Перейти на следующий тест"
        }
    }

    private func openMistakesChat() {
        if !UsageLimits.shared.canUseAkzhol { showPaywall = true; return }
        let chat = ChatViewModel()
        chat.onLimitReached = { showPaywall = true }
        chat.pendingContext = AIContext.buildMistakesWorkContextRu(
            questions: result.questions, userChoices: result.userChoices)
        chat.input = "Разбери мои ошибки и объясни верные ответы"
        mistakesChat = chat
    }
}
