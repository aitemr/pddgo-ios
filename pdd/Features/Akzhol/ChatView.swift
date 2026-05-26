//
//  ChatView.swift
//  pdd
//
//  Shared chat experience used by the Акжол tab and the in-quiz AI sheet.
//

import SwiftUI
import Observation

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var input = ""
    var pendingImages: [Data] = []
    private(set) var isSending = false
    /// Pending quiz-error context attached to the next user message.
    var pendingContext: String?
    /// Invoked when the free Akzhol turn limit is hit.
    var onLimitReached: (() -> Void)?

    var canSend: Bool {
        !isSending && (!input.trimmingCharacters(in: .whitespaces).isEmpty || !pendingImages.isEmpty)
    }

    func seedGreeting() {
        guard messages.isEmpty else { return }
    }

    func send() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty || !pendingImages.isEmpty else { return }

        if !UsageLimits.shared.canUseAkzhol {
            onLimitReached?()
            return
        }

        let user = ChatMessage(text: text, isUser: true, imageDatas: pendingImages,
                               quizContextForApi: pendingContext)
        messages.append(user)
        input = ""
        pendingImages = []
        pendingContext = nil

        let typing = ChatMessage(text: "", isUser: false, isTyping: true)
        messages.append(typing)
        isSending = true
        UsageLimits.shared.recordAkzholTurn()

        let history = messages.filter { !$0.isTyping }
        let lang = Session.shared.language
        Task { @MainActor in
            let reply: String
            do { reply = try await AkzholService.shared.reply(history: history, lang: lang) }
            catch { reply = "Не удалось получить ответ. Попробуйте ещё раз." }
            if let idx = messages.firstIndex(where: { $0.id == typing.id }) {
                messages[idx] = ChatMessage(text: reply, isUser: false)
            }
            isSending = false
        }
    }
}

struct ChatView: View {
    @Bindable var vm: ChatViewModel
    var showsCamera: Bool = true
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(vm.messages) { MessageBubble(message: $0) }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .onChange(of: vm.messages.count) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
            inputBar
        }
        .background(.white)
    }

    private var inputBar: some View {
        VStack(spacing: 8) {
            if !vm.pendingImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(vm.pendingImages.enumerated()), id: \.offset) { _, data in
                            if let ui = UIImage(data: data) {
                                Image(uiImage: ui).resizable().scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            HStack(spacing: 12) {
                TextField("Напишите свой вопрос", text: $vm.input)
                    .font(.app(16))
                    .foregroundStyle(AppColor.textBlack)
                    .focused($focused)
                    .submitLabel(.send)
                    .onSubmit(vm.send)
                CircleIconButton(systemName: "paperplane.fill", enabled: vm.canSend, action: vm.send)
            }
            .padding(.leading, 18).padding(.trailing, 9)
            .frame(height: 64)
            .background(AppColor.lightBg, in: Capsule())
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                if !message.imageDatas.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(message.imageDatas.enumerated()), id: \.offset) { _, data in
                            if let ui = UIImage(data: data) {
                                Image(uiImage: ui).resizable().scaledToFill()
                                    .frame(width: 92, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                }
                if message.isTyping {
                    HStack(spacing: 10) {
                        Text("Думает что ответить...").font(.app(16)).foregroundStyle(AppColor.greyText)
                        TypingDots()
                    }
                    .padding(.horizontal, 18).padding(.vertical, 14)
                    .background(AppColor.lightBg, in: bubble)
                } else if !message.text.isEmpty {
                    Text(message.text)
                        .font(.app(16))
                        .foregroundStyle(message.isUser ? .white : AppColor.textBlack)
                        .lineSpacing(3)
                        .padding(.horizontal, 18).padding(.vertical, 14)
                        .background(message.isUser ? AppColor.brandBlue : AppColor.lightBg, in: bubble)
                }
            }
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
    private var bubble: some Shape { RoundedRectangle(cornerRadius: 20, style: .continuous) }
}
