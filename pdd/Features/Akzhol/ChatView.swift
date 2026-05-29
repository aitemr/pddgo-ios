//
//  ChatView.swift
//  pdd
//
//  Shared chat experience (Акжол tab + in-quiz AI sheet) — matches Flutter.
//

import SwiftUI
import Observation
internal import Combine

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var input = ""
    var pendingImages: [Data] = []
    private(set) var isSending = false
    var pendingContext: String?
    var onLimitReached: (() -> Void)?

    var canSend: Bool {
        !isSending && (!input.trimmingCharacters(in: .whitespaces).isEmpty || !pendingImages.isEmpty)
    }

    func send() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty || !pendingImages.isEmpty else { return }
        if !UsageLimits.shared.canUseAkzhol { onLimitReached?(); return }

        messages.append(ChatMessage(text: text, isUser: true, imageDatas: pendingImages, quizContextForApi: pendingContext))
        input = ""; pendingImages = []; pendingContext = nil

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

/// Chat input pill with in-bar camera (purple) + send (blue) — matches chat_input.dart.
struct ChatInputBar: View {
    @Bindable var vm: ChatViewModel
    var showCamera: Bool = true
    var onCamera: () -> Void = {}
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 10) {
            if !vm.pendingImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(vm.pendingImages.enumerated()), id: \.offset) { idx, data in
                            if let ui = UIImage(data: data) {
                                Image(uiImage: ui).resizable().scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(alignment: .topTrailing) {
                                        Button { vm.pendingImages.remove(at: idx) } label: {
                                            Image(systemName: "xmark").font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.white).frame(width: 18, height: 18)
                                                .background(.black.opacity(0.54), in: Circle())
                                        }
                                        .accessibilityLabel(L.chatRemovePhoto)
                                        .padding(4)
                                    }
                            }
                        }
                    }
                }
                .frame(height: 72)
            }
            HStack(spacing: 8) {
                TextField(L.chatInputHint, text: $vm.input)
                    .font(.system(size: 16, design: .rounded)).appKerning(16)
                    .foregroundStyle(AppColor.textBlack)
                    .focused($focused).submitLabel(.send).onSubmit(vm.send)
                if showCamera {
                    Button(action: onCamera) {
                        Image(systemName: "camera.fill").font(.system(size: 20)).foregroundStyle(.white)
                            .frame(width: 42, height: 42).background(Color(hex: "#7B61FF"), in: Circle())
                    }.buttonStyle(.plain)
                    .accessibilityLabel(L.chatAttachPhoto)
                }
                Button(action: vm.send) {
                    Image(systemName: "paperplane.fill").font(.system(size: 17)).foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Color(hex: "#3B82F6"), in: RoundedRectangle(cornerRadius: 30))
                }.buttonStyle(.plain)
                .accessibilityLabel(L.chatSend)
            }
            .padding(.leading, 16).padding(.trailing, showCamera ? 10 : 16)
            .frame(height: 72)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
        }
        .padding(.horizontal, 20)
    }
}

struct ChatView: View {
    @Bindable var vm: ChatViewModel
    var showsCamera: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(vm.messages) { MessageBubble(message: $0) }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 30).padding(.top, 8)
                }
                .onChange(of: vm.messages.count) { _, _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
            }
            ChatInputBar(vm: vm, showCamera: showsCamera).padding(.bottom, 12)
        }
        .background(.white)
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
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                        }
                    }
                }
                if message.isTyping {
                    TypingDotsBlack()
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else if !message.text.isEmpty {
                    if message.isUser {
                        Text(message.text).font(.system(size: 16, design: .rounded))
                            .foregroundStyle(.white).padding(14)
                            .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .frame(maxWidth: 280, alignment: .trailing)
                    } else {
                        MarkdownText(message.text).padding(14)
                            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .frame(maxWidth: 300, alignment: .leading)
                    }
                }
            }
            .padding(.vertical, 6)
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}

struct TypingDotsBlack: View {
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle().fill(.black.opacity(i <= phase ? 1 : 0.25)).frame(width: 8, height: 8)
            }
        }
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}
