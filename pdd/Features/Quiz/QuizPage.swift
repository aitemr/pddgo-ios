//
//  QuizPage.swift
//  pdd
//
//  Faithful port of quiz_page.dart.
//

import SwiftUI

struct QuizPage: View {
    @Bindable var vm: QuizViewModel
    var onClose: () -> Void

    @State private var askVM: ChatViewModel?
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 0) {
            appBar
            chipRow
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(vm.current.localizedQuestion(vm.lang))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A1A"))
                        .lineSpacing(5)
                    VStack(spacing: 12) {
                        ForEach(Array(vm.current.answers.enumerated()), id: \.offset) { i, ans in
                            OptionTile(
                                text: ans.localized(vm.lang),
                                state: state(for: i),
                                explanation: (vm.isAnswerSubmitted && i == vm.current.correctIndex)
                                    ? vm.current.localizedExplanation(vm.lang) : nil
                            ) { vm.selectOption(i) }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .id(vm.currentIndex)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal:   .opacity.combined(with: .move(edge: .leading))
                ))
            }
            .animation(AppAnimation.page, value: vm.currentIndex)
            bottomBar
        }
        .background(.white)
        .onAppear { vm.start() }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $askVM) { vm in
            AskAkzholSheet(vm: vm).presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    // MARK: App bar (blue)

    private var appBar: some View {
        HStack(spacing: 4) {
            Button(action: vm.currentIndex > 0 ? vm.goBack : onClose) {
                Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
            }.buttonStyle(.plain)
            Text("\(vm.currentIndex + 1) / \(vm.total)")
                .font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundStyle(.white)
            Spacer()
            if vm.config.timeLimit != nil && !vm.isReplay {
                Text(formatMMSS(vm.remainingSeconds))
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 12)
        .background(AppColor.brandBlue)
    }

    // MARK: Chip row

    private var chipRow: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<vm.total, id: \.self) { i in
                        chip(i).id(i)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 9)
            }
            .frame(height: 54)
            .overlay(alignment: .bottom) { Rectangle().fill(Color(hex: "#EEEEEE")).frame(height: 1) }
            .onChange(of: vm.currentIndex) { _, i in withAnimation { proxy.scrollTo(i, anchor: .center) } }
        }
    }

    private func chip(_ i: Int) -> some View {
        let isCurrent = i == vm.currentIndex
        let st = vm.questionState(i)
        var border = Color(hex: "#DDDDDD"); var text = Color(hex: "#999999"); var fill = Color.clear
        switch st {
        case .correct: border = AppColor.greenSuccess; text = AppColor.greenSuccess; fill = AppColor.greenSuccess.opacity(0.12)
        case .wrong: border = AppColor.redError; text = AppColor.redError; fill = AppColor.redError.opacity(0.12)
        case .unanswered: break
        }
        if isCurrent { border = AppColor.brandBlue; text = AppColor.brandBlue; fill = AppColor.brandBlue.opacity(0.10) }
        return Button { vm.goToQuestion(i) } label: {
            Text("\(i + 1)")
                .font(.system(size: 12, weight: isCurrent ? .bold : .medium, design: .rounded))
                .foregroundStyle(text)
                .frame(width: 36, height: 36)
                .background(fill, in: Circle())
                .overlay(Circle().stroke(border, lineWidth: isCurrent ? 2 : 1))
        }.buttonStyle(.plain)
    }

    private func state(for i: Int) -> OptionTile.State {
        if vm.isAnswerSubmitted {
            if i == vm.current.correctIndex { return .correct }
            if i == vm.selectedOptionIndex { return .incorrect }
            return .normal
        }
        return i == vm.selectedOptionIndex ? .selected : .normal
    }

    // MARK: Bottom bar

    private var akzholEnabled: Bool {
        vm.isAnswerSubmitted && vm.selectedOptionIndex != nil && vm.selectedOptionIndex != vm.current.correctIndex
    }
    private var btnText: String {
        if !vm.isAnswerSubmitted { return L.quizCheck }
        return vm.isLastQuestion ? L.quizFinish : L.quizNext
    }
    private var btnActive: Bool { vm.isAnswerSubmitted || vm.selectedOptionIndex != nil }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            iconBtn("chevron.left", interactive: vm.canGoBack) { vm.goBack() }
            iconBtn(vm.isCurrentFavorite ? "star.fill" : "star",
                    interactive: true,
                    dimmed: !vm.isAnswerSubmitted && !vm.isCurrentFavorite,
                    color: vm.isCurrentFavorite ? Color(hex: "#FFB800") : nil) { vm.toggleFavorite() }
            akzholAvatarBtn
            Spacer()
            Button(action: primaryAction) {
                Text(btnText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(btnActive ? .white : .gray)
                    .padding(.horizontal, 14).frame(height: 44)
                    .background(btnActive ? AppColor.brandBlue : Color(hex: "#E0E0E0"), in: Capsule())
            }.buttonStyle(.plain).disabled(!btnActive)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 12, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var akzholAvatarBtn: some View {
        Button(action: openAsk) {
            Image("akzhol").resizable().scaledToFill()
                .frame(width: 24, height: 24).clipShape(Circle()).background(AppColor.brandBlue, in: Circle())
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color(hex: "#E0E0E0"), lineWidth: 1.5))
                .opacity(akzholEnabled ? 1 : 0.38)
        }.buttonStyle(.plain).disabled(!akzholEnabled)
    }

    private func iconBtn(_ icon: String, interactive: Bool, dimmed: Bool = false, color: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color ?? Color(hex: "#666666"))
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color(hex: "#E0E0E0"), lineWidth: 1.5))
                .opacity((!interactive || dimmed) ? 0.32 : 1)
        }.buttonStyle(.plain).disabled(!interactive)
    }

    private func primaryAction() {
        if vm.isReplay { vm.isLastQuestion ? onClose() : vm.goNext(); return }
        if !vm.isAnswerSubmitted { vm.submitAnswer() } else { vm.goNext() }
    }

    private func openAsk() {
        guard akzholEnabled else { return }
        if !UsageLimits.shared.canUseAkzhol { showPaywall = true; return }
        let chat = ChatViewModel()
        chat.onLimitReached = { showPaywall = true }
        chat.pendingContext = AIContext.buildMistakesWorkContextRu(
            questions: [vm.current], userChoices: [vm.selectedOptionIndex])
        chat.input = L.aiDefaultQuestion
        askVM = chat
    }
}

extension ChatViewModel: Identifiable {}

// MARK: - Option tile

struct OptionTile: View {
    enum State { case normal, selected, correct, incorrect }
    let text: String
    let state: State
    var explanation: String?
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(iconColor)
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.bounce, value: isResolved)
                    Text(text).font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.black).multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(16)
                .background(bg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: borderWidth))
                .scaleEffect(state == .selected ? 0.98 : 1)
                .animation(AppAnimation.snappy, value: state)
            }
            .buttonStyle(.plain)
            .disabled(state == .correct || state == .incorrect || isSubmittedNormal)

            if let explanation, !explanation.isEmpty {
                Text(L.quizCorrectPrefix + explanation)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Color(hex: "#898989")).lineSpacing(2)
                    .padding(.top, 8).padding(.bottom, 12).padding(.leading, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(AppAnimation.snappy, value: explanation)
    }

    private var isResolved: Bool { state == .correct || state == .incorrect }

    // When submitted, normal (non-selected, non-correct) tiles are non-interactive.
    private var isSubmittedNormal: Bool { false }

    private var icon: String {
        switch state {
        case .correct: "checkmark.circle.fill"
        case .incorrect: "xmark.circle.fill"
        case .selected: "largecircle.fill.circle"
        case .normal: "circle"
        }
    }
    private var iconColor: Color {
        switch state {
        case .correct: AppColor.greenSuccess
        case .incorrect: AppColor.redError
        case .selected: AppColor.brandBlue
        case .normal: AppColor.greyText
        }
    }
    private var bg: Color {
        switch state {
        case .correct: AppColor.greenSuccess.opacity(0.10)
        case .incorrect: AppColor.redError.opacity(0.10)
        case .selected: AppColor.brandBlue.opacity(0.10)
        case .normal: .white
        }
    }
    private var border: Color {
        switch state {
        case .correct: AppColor.greenSuccess
        case .incorrect: AppColor.redError
        case .selected: AppColor.brandBlue
        case .normal: Color(hex: "#D5D5D5")
        }
    }
    private var borderWidth: CGFloat { state == .normal ? 1 : 2 }
}

// MARK: - In-quiz AI sheet

struct AskAkzholSheet: View {
    @Bindable var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("akzhol").resizable().scaledToFill()
                    .frame(width: 36, height: 36).clipShape(Circle()).background(AppColor.brandBlue, in: Circle())
                Text(L.askAkzhol).font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "chevron.down").font(.system(size: 18, weight: .semibold)).foregroundStyle(AppColor.brandBlue)
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            Divider()
            ChatView(vm: vm)
        }
    }
}
