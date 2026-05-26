//
//  ProfileRootView.swift
//  pdd
//
//  Profile tab (spec §10).
//

import SwiftUI
import StoreKit

enum ProfileRoute: Hashable { case edit, favorites, legal(String) }

struct ProfileRootView: View {
    @State private var path = NavigationPath()
    @State private var session = Session.shared
    @State private var progress = ProgressStore.shared
    @State private var subs = SubscriptionGate.shared

    @State private var showPaywall = false
    @State private var showLanguage = false
    @State private var confirmLogout = false
    @State private var confirmDelete = false
    @Environment(\.requestReview) private var requestReview
    @Environment(AppState.self) private var app

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    levelCard
                    notificationsBlock
                    menu
                    dangerZone
                }
                .padding(.horizontal, AppLayout.profileMargin)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(.white)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .edit: EditProfileView()
                case .favorites: FavoritesView()
                case .legal(let title): LegalView(title: title)
                }
            }
            .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
            .sheet(isPresented: $showLanguage) { LanguageSheet() }
            .confirmationDialog("Выйти из аккаунта?", isPresented: $confirmLogout, titleVisibility: .visible) {
                Button("Выйти", role: .destructive) { app.signOut() }
            }
            .confirmationDialog("Удалить аккаунт? Это действие необратимо.", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { app.deleteAccount() }
            }
        }
    }

    // MARK: Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            avatar
            Text(session.displayUser.fullName.isEmpty ? "Гость" : session.displayUser.fullName)
                .font(.app(30, .bold)).foregroundStyle(AppColor.textBlack)
            HStack(spacing: 8) {
                providerBadge
                Text(session.displayUser.licenseCategory)
                    .font(.app(13, .medium)).foregroundStyle(AppColor.greyText)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(AppColor.lightBg, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var avatar: some View {
        Group {
            if !session.displayUser.photoUrl.isEmpty, let url = URL(string: session.displayUser.photoUrl) {
                AsyncImage(url: url) { $0.resizable().scaledToFill() } placeholder: { Image("profile").resizable().scaledToFill() }
            } else {
                Image("profile").resizable().scaledToFill()
            }
        }
        .frame(width: 120, height: 120).clipShape(Circle())
        .overlay(Circle().stroke(AppColor.lightBg, lineWidth: 4))
    }

    private var providerBadge: some View {
        let p = session.displayUser.provider
        let label = p == .google ? "Google" : p == .apple ? "Apple" : "Demo"
        return Text(label).font(.app(13, .medium)).foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(AppColor.brandBlue, in: Capsule())
    }

    // MARK: Level card

    private var levelCard: some View {
        let acc = progress.overallAccuracy
        let label = acc >= 0.75 ? "Эксперт" : acc >= 0.35 ? "Водитель" : "Новичок"
        return VStack(alignment: .leading, spacing: 10) {
            Text("Ваш уровень").font(.app(15, .medium)).foregroundStyle(.white.opacity(0.85))
            Text(label).font(.app(26, .bold)).foregroundStyle(.white)
            ProgressView(value: Double(progress.correctTotal), total: Double(max(progress.answeredTotal, 1)))
                .tint(.white)
            Text("\(progress.correctTotal) / \(progress.answeredTotal) правильных ответов")
                .font(.app(13)).foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [AppColor.brandBlue, AppColor.brandBlue2],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: Notifications

    private var notificationsBlock: some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(get: { session.notificationsEnabled }, set: { on in
                session.notificationsEnabled = on
                if on { Task { _ = await PushService.shared.requestAuthorization() } }
                else { PushService.shared.disable() }
            })) {
                rowLabel("bell.fill", "Уведомления")
            }.tint(AppColor.brandBlue).padding(.horizontal, 16).frame(height: 56)
            divider
            Toggle(isOn: $session.hapticsEnabled) { rowLabel("iphone.radiowaves.left.and.right", "Вибрация") }
                .tint(AppColor.brandBlue).padding(.horizontal, 16).frame(height: 56)
        }
        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: Menu

    private var menu: some View {
        VStack(spacing: 0) {
            menuRow("crown.fill", subs.isPremium ? "Premium активен" : "Premium") { showPaywall = true }
            divider
            menuRow("star.fill", "Избранное") { path.append(ProfileRoute.favorites) }
            divider
            menuRow("person.crop.circle", "Редактировать профиль") { path.append(ProfileRoute.edit) }
            divider
            menuRow("globe", "Выбрать язык", trailing: session.language.flag) { showLanguage = true }
            divider
            menuRow("lock.shield", "Политика конфиденциальности") { path.append(ProfileRoute.legal("Политика конфиденциальности")) }
            divider
            menuRow("doc.text", "Условия использования") { path.append(ProfileRoute.legal("Условия использования")) }
            divider
            Toggle(isOn: $session.animationsEnabled) { rowLabel("sparkles", "Анимации") }
                .tint(AppColor.brandBlue).padding(.horizontal, 16).frame(height: 56)
            divider
            menuRow("star.bubble", "Оценить приложение") { requestReview() }
            divider
            ShareLink(item: URL(string: "https://apps.apple.com/app/id000000000")!) {
                rowLabel("square.and.arrow.up", "Поделиться")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16).frame(height: 56)
            }
        }
        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var dangerZone: some View {
        VStack(spacing: 12) {
            SecondaryButton(title: "Поддержка") { }
            Button { confirmLogout = true } label: {
                Text("Выйти").font(.app(16, .semibold)).foregroundStyle(AppColor.redError)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(AppColor.redBg, in: Capsule())
            }.buttonStyle(.plain)
            Button { confirmDelete = true } label: {
                Text("Удалить аккаунт").font(.app(14, .medium)).foregroundStyle(AppColor.greyText)
            }.buttonStyle(.plain).padding(.top, 4)
        }
    }

    // MARK: Bits

    private func rowLabel(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.brandBlue).frame(width: 24)
            Text(title).font(.app(16)).foregroundStyle(AppColor.textBlack)
        }
    }
    private func menuRow(_ icon: String, _ title: String, trailing: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                rowLabel(icon, title)
                Spacer()
                if let trailing { Text(trailing).font(.app(15)) }
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.tabInactive)
            }
            .padding(.horizontal, 16).frame(height: 56).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
    private var divider: some View {
        Rectangle().fill(AppColor.divider).frame(height: 1).padding(.leading, 54)
    }
}

struct LegalView: View {
    let title: String
    var body: some View {
        ScrollView {
            Text("Здесь размещается текст документа «\(title)». В продакшене загружается с сервера или из локального ресурса.")
                .font(.app(16)).foregroundStyle(AppColor.textBlack)
                .padding(AppLayout.profileMargin)
        }
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}
