//
//  AkzholRootView.swift
//  pdd
//
//  Акжол tab: hero empty state + conversation, camera attachments, 3-turn limit.
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
                AkzholHero()
            } else {
                conversationHeader
                conversationList
            }
            inputArea
        }
        .background(.white)
        .contentShape(Rectangle())
        .onTapGesture { focused = false }
        .onAppear { vm.onLimitReached = { showPaywall = true } }
        .sheet(isPresented: $showPicker) {
            PhotoPicker { data in vm.pendingImages.append(data) }
        }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    private var conversationHeader: some View {
        HStack(spacing: 12) {
            Image("AkzholAvatar").resizable().scaledToFill()
                .frame(width: 44, height: 44).background(AppColor.brandBlue2).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Акжол").font(.app(18, .semibold)).foregroundStyle(AppColor.textBlack)
                Text("Сотрудник МВД РК").font(.app(13)).foregroundStyle(AppColor.greyText)
            }
            Spacer()
        }
        .padding(.horizontal, AppLayout.homeMargin).padding(.vertical, 14)
    }

    private var conversationList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(vm.messages) { MessageBubble(message: $0) }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, AppLayout.homeMargin).padding(.top, 4)
            }
            .onChange(of: vm.messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    // MARK: Input + camera FAB

    private var inputArea: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                if !vm.pendingImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(vm.pendingImages.enumerated()), id: \.offset) { idx, data in
                                if let ui = UIImage(data: data) {
                                    Image(uiImage: ui).resizable().scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(alignment: .topTrailing) {
                                            Button { vm.pendingImages.remove(at: idx) } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, .black.opacity(0.5))
                                            }
                                        }
                                }
                            }
                        }.padding(.horizontal, AppLayout.homeMargin)
                    }
                }
                HStack(spacing: 12) {
                    TextField("Напишите свой вопрос", text: $vm.input)
                        .font(.app(16)).foregroundStyle(AppColor.textBlack)
                        .focused($focused).submitLabel(.send).onSubmit(vm.send)
                    CircleIconButton(systemName: "paperplane.fill", enabled: vm.canSend, action: vm.send)
                }
                .padding(.leading, 18).padding(.trailing, 9)
                .frame(height: 72)
                .background(AppColor.lightBg, in: Capsule())
                .padding(.horizontal, AppLayout.homeMargin)
            }
            .padding(.top, 8)

            Button { showPicker = true } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22, weight: .medium)).foregroundStyle(.white)
                    .frame(width: 57, height: 57)
                    .background(AppColor.purple, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 36)
            .offset(y: -69)
        }
    }
}

// MARK: - Hero (empty state)

private struct AkzholHero: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image("AkzholAvatar").resizable().scaledToFill()
                    .frame(width: 120, height: 120).background(AppColor.brandBlue2).clipShape(Circle())
                    .padding(.top, 24)
                Text("Здравия желаю,\nменя зовут Акжол")
                    .font(.app(34, .semibold)).foregroundStyle(AppColor.textBlack)
                    .multilineTextAlignment(.center).lineSpacing(2).padding(.top, 20)
                Text("Я могу вам помочь с:")
                    .font(.app(16, .medium)).foregroundStyle(AppColor.textBlack).padding(.top, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) { ForEach(HelpCard.all) { HelpCardView(card: $0) } }
                        .padding(.horizontal, AppLayout.homeMargin)
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct HelpCard: Identifiable {
    enum Icon { case flag, book, chat }
    let id = UUID()
    let icon: Icon; let title: String; let body: String
    static let all: [HelpCard] = [
        .init(icon: .flag, title: "С решением вопросов по ПДД РК",
              body: "Оформление ДТП, спорные ситуации и взаимодействие с органами — быстро, профессионально и в рамках закона"),
        .init(icon: .book, title: "Помогу тебе с экзаменационными вопросами ПДД",
              body: "Разбираем спорные формулировки, обновлённые требования и реальные дорожные ситуации"),
        .init(icon: .chat, title: "Отвечу на любые твои вопросы по вождению",
              body: "От теории ПДД до реальных ситуаций на дороге. Объясняю понятно, без занудства и лишних терминов"),
    ]
}

private struct HelpCardView: View {
    let card: HelpCard
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            ZStack {
                Circle().fill(AppColor.brandBlue2).frame(width: 56, height: 56)
                switch card.icon {
                case .flag: Image("KZ").resizable().scaledToFit().frame(width: 38, height: 38)
                case .book: Image(systemName: "book.fill").font(.system(size: 24)).foregroundStyle(.white)
                case .chat: VoiceChatGlyph().frame(width: 26, height: 26).foregroundStyle(.white)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(card.title).font(.app(16, .semibold)).foregroundStyle(.black).lineSpacing(1)
                Text(card.body).font(.app(12)).foregroundStyle(.black).lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 252, height: 249, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.cardBorder, lineWidth: 1))
    }
}
