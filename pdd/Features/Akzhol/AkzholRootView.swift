//
//  AkzholRootView.swift
//  pdd
//
//  Акжол tab — faithful port of ai_start_view.dart + ai_chat_page.dart.
//

import SwiftUI

struct AkzholRootView: View {
    @State private var vm = ChatViewModel()
    @State private var showPicker = false
    @State private var showPaywall = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if vm.messages.isEmpty {
                AkzholStartView(vm: vm, onCamera: { showPicker = true })
            } else {
                chatHeader
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(vm.messages) { MessageBubble(message: $0) }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, 30).padding(.top, 4)
                    }
                    .onChange(of: vm.messages.count) { _, _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
                }
                ChatInputBar(vm: vm, onCamera: { showPicker = true }).padding(.bottom, 8)
            }
        }
        .background(.white)
        .onAppear { vm.onLimitReached = { showPaywall = true } }
        .sheet(isPresented: $showPicker) { PhotoPicker { vm.pendingImages.append($0) } }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    private var chatHeader: some View {
        HStack(spacing: 10) {
            Image("ai_akzhol").resizable().scaledToFit().frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 0) {
                Text(L.akzholName).font(.system(size: 20, weight: .semibold, design: .rounded)).appKerning(20)
                    .foregroundStyle(AppColor.textBlack)
                Text(L.akzholRole).font(.system(size: 14, weight: .semibold, design: .rounded)).appKerning(14)
                    .foregroundStyle(AppColor.greyText)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
    }
}

private struct AkzholStartView: View {
    @Bindable var vm: ChatViewModel
    var onCamera: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Image("ai_akzhol").resizable().scaledToFit().frame(width: 120, height: 120).padding(.top, 36)
                    Text(L.akzholGreeting)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center).lineSpacing(1)
                        .foregroundStyle(AppColor.textBlack).padding(.horizontal, 32).padding(.top, 16)
                    Text(L.akzholCanHelp)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textBlack).padding(.top, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            helpCard("flag", L.akzholCard1Title, L.akzholCard1Subtitle)
                            helpCard("info", L.akzholCard2Title, L.akzholCard2Subtitle)
                            helpCard("quest", L.akzholCard3Title, L.akzholCard3Subtitle)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                }
            }
            ChatInputBar(vm: vm, onCamera: onCamera).padding(.bottom, 8)
        }
    }

    private func helpCard(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(icon).resizable().scaledToFit().frame(width: 48, height: 48)
            Text(title).font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#1C1C1E")).lineSpacing(2).padding(.top, 16)
            Text(subtitle).font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color(hex: "#636366")).lineSpacing(3).padding(.top, 8)
            Spacer(minLength: 0)
        }
        .padding(.init(top: 20, leading: 18, bottom: 20, trailing: 18))
        .frame(width: 280, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.cardBorder, lineWidth: 1))
    }
}
