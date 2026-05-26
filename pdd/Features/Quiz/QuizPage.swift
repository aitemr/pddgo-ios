//
//  QuizPage.swift
//  pdd
//
//  Question screen (Figma): optional media, prompt, answer states, bottom panel.
//

import SwiftUI
import AVKit

struct QuizPage: View {
    @Bindable var vm: QuizViewModel
    var onClose: () -> Void

    @State private var askVM: ChatViewModel?
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let url = vm.current.videoURL {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 230)
                            .clipped()
                            .padding(.bottom, 20)
                    }
                    Text(vm.current.localizedQuestion(vm.lang))
                        .font(.app(20, .medium))
                        .foregroundStyle(AppColor.textBlack)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, AppLayout.homeMargin)
                        .padding(.top, vm.current.videoURL == nil ? 12 : 0)

                    answers.padding(.top, 24)
                }
                .padding(.bottom, 24)
            }
            bottomPanel
        }
        .background(.white)
        .onAppear { vm.start() }
        .sheet(item: $askVM) { vm in
            AskAkzholSheet(vm: vm)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(canDismiss: true)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            BackButton(action: vm.currentIndex > 0 ? vm.goBack : onClose)
            Spacer()
            Text("\(vm.currentIndex + 1)/\(vm.total)")
                .font(.app(18, .medium)).foregroundStyle(AppColor.textBlack)
            Spacer()
            if vm.config.timeLimit != nil && !vm.isReplay {
                Text(formatMMSS(vm.remainingSeconds))
                    .font(.app(15, .semibold).monospacedDigit())
                    .foregroundStyle(vm.remainingSeconds < 60 ? AppColor.redError : AppColor.greyText)
                    .frame(width: 32)
            } else {
                favoriteButton
            }
        }
        .padding(.horizontal, AppLayout.homeMargin)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .overlay(alignment: .topTrailing) {
            if vm.config.timeLimit != nil && !vm.isReplay { EmptyView() }
        }
    }

    private var favoriteButton: some View {
        Button {
            vm.toggleFavorite()
        } label: {
            Image(systemName: vm.isCurrentFavorite ? "star.fill" : "star")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(vm.canFavorite ? AppColor.orange : AppColor.tabInactive)
        }
        .buttonStyle(.plain)
        .disabled(!vm.canFavorite)
    }

    // MARK: Answers

    private var answers: some View {
        VStack(spacing: 10) {
            ForEach(Array(vm.current.answers.enumerated()), id: \.offset) { i, ans in
                AnswerRow(
                    text: ans.localized(vm.lang),
                    state: state(for: i),
                    explanation: (vm.isAnswerSubmitted && i == vm.current.correctIndex)
                        ? vm.current.localizedExplanation(vm.lang) : nil
                ) {
                    vm.selectOption(i)
                }
            }
        }
        .padding(.horizontal, AppLayout.homeMargin)
    }

    private func state(for i: Int) -> AnswerRow.State {
        if vm.isAnswerSubmitted {
            if i == vm.current.correctIndex { return .correct }
            if i == vm.selectedOptionIndex { return .incorrect }
            return .dimmed
        }
        return i == vm.selectedOptionIndex ? .selected : .normal
    }

    // MARK: Bottom panel

    private var bottomPanel: some View {
        HStack(spacing: 12) {
            Button(action: openAsk) {
                HStack(spacing: 10) {
                    Image("AkzholAvatar").resizable().scaledToFill()
                        .frame(width: 32, height: 32).clipShape(Circle())
                        .background(AppColor.brandBlue2, in: Circle())
                    Text("Спросить Акжола")
                        .font(.app(16, .medium))
                        .foregroundStyle(vm.canAskAkzhol ? AppColor.textBlack : AppColor.tabInactive)
                }
            }
            .buttonStyle(.plain)
            .disabled(!vm.canAskAkzhol)

            Spacer()

            CircleIconButton(
                systemName: arrowSymbol,
                size: 48,
                enabled: arrowEnabled,
                action: primaryAction
            )
        }
        .padding(.horizontal, AppLayout.homeMargin)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                .fill(.white)
                .overlay(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                    .stroke(AppColor.navBorder, lineWidth: 1))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var arrowSymbol: String {
        if vm.isReplay { return "chevron.right" }
        if !vm.isAnswerSubmitted { return "checkmark" }
        return vm.isLastQuestion ? "flag.checkered" : "chevron.right"
    }
    private var arrowEnabled: Bool {
        vm.isReplay || vm.selectedOptionIndex != nil
    }
    private func primaryAction() {
        if vm.isReplay { vm.isLastQuestion ? onClose() : vm.goNext(); return }
        if !vm.isAnswerSubmitted { vm.submitAnswer() } else { vm.goNext() }
    }

    // MARK: AI

    private func openAsk() {
        guard vm.canAskAkzhol else { return }
        let chat = ChatViewModel()
        chat.onLimitReached = { showPaywall = true }
        chat.pendingContext = AIContext.buildMistakesWorkContextRu(
            questions: [vm.current], userChoices: [vm.selectedOptionIndex]
        )
        chat.input = "Почему мой ответ был неверным?"
        askVM = chat
    }
}

extension ChatViewModel: Identifiable {}

// MARK: - Answer row

struct AnswerRow: View {
    enum State { case normal, selected, correct, incorrect, dimmed }

    let text: String
    let state: State
    var explanation: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    indicator
                    Text(text)
                        .font(.app(16))
                        .foregroundStyle(AppColor.textBlack)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                if let explanation, !explanation.isEmpty {
                    Text(explanation)
                        .font(.app(14))
                        .foregroundStyle(AppColor.greyText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 40)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var indicator: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26)).foregroundStyle(AppColor.greenSuccess)
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 26)).foregroundStyle(AppColor.redError)
        case .selected:
            Image(systemName: "largecircle.fill.circle")
                .font(.system(size: 26)).foregroundStyle(AppColor.brandBlue)
        default:
            Circle().stroke(Color(hex: "#D2D2D2"), lineWidth: 2).frame(width: 26, height: 26)
        }
    }

    private var rowBackground: Color {
        switch state {
        case .correct, .incorrect: AppColor.lightBg
        default: .clear
        }
    }
}

// MARK: - In-quiz AI sheet

struct AskAkzholSheet: View {
    @Bindable var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("AkzholAvatar").resizable().scaledToFill()
                    .frame(width: 36, height: 36).clipShape(Circle())
                Text("Спросить Акжола").font(.app(18, .semibold)).foregroundStyle(AppColor.textBlack)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.brandBlue)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            Divider()
            ChatView(vm: vm)
        }
    }
}
