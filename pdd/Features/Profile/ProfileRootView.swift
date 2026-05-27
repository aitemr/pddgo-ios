//
//  ProfileRootView.swift
//  pdd
//
//  Faithful port of profile_page.dart.
//

import SwiftUI
import StoreKit

enum ProfileRoute: Hashable { case edit, favorites }

struct ProfileRootView: View {
    @State private var path = NavigationPath()
    @State private var session = Session.shared
    @State private var progress = ProgressStore.shared

    @State private var showPaywall = false
    @State private var showLanguage = false
    @State private var confirmLogout = false
    @Environment(\.requestReview) private var requestReview
    @Environment(AppState.self) private var app

    private var isGuest: Bool { session.displayUser.provider == .demo }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Image("profile").resizable().scaledToFit().frame(width: 150, height: 150)
                        .padding(.top, 40)
                    Text(session.displayUser.fullName.isEmpty ? L.profileDemoUserName : session.displayUser.fullName)
                        .font(.system(size: 36, weight: .bold, design: .rounded)).appKerning(36)
                        .foregroundStyle(AppColor.textBlack).padding(.top, 20)
                    providerBadge.padding(.top, 4)
                    Text(session.displayUser.licenseCategory.isEmpty ? L.licenseCatB : session.displayUser.licenseCategory)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color(hex: "#B6B6B6")).padding(.top, 4)

                    VStack(spacing: 0) {
                        levelCard.padding(.top, 32)
                        notificationsCard.padding(.top, 24)
                        menuCard.padding(.top, 16)
                        supportButton.padding(.top, 12)
                        logoutButton.padding(.top, 36)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 60)
            }
            .background(.white)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .edit: EditProfileView()
                case .favorites: FavoritesView()
                }
            }
            .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
            .sheet(isPresented: $showLanguage) { LanguageSheet() }
            .confirmationDialog(L.logoutConfirmTitle, isPresented: $confirmLogout, titleVisibility: .visible) {
                Button(L.logoutConfirmButton, role: .destructive) { app.signOut() }
                Button(L.cancel, role: .cancel) {}
            } message: { Text(L.logoutConfirmMessage) }
        }
    }

    private var providerBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.crop.circle").font(.system(size: 14)).foregroundStyle(Color(hex: "#B6B6B6"))
            Text(L.profileDemoUserName).font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#B6B6B6"))
        }
        .padding(.horizontal, 12).padding(.vertical, 4)
        .background(Color(hex: "#F5F5F5"), in: Capsule())
    }

    // MARK: Level

    private var levelCard: some View {
        let done = progress.correctTotal
        let total = max(QuizRules.questionBankTotal, 1)
        let ratio = min(1.0, Double(done) / Double(total))
        let label = ratio >= 0.75 ? L.profileLevelExpert : ratio >= 0.35 ? L.profileLevelDriver : L.profileLevelLearner
        return VStack(alignment: .leading, spacing: 0) {
            Text(L.profileLevelTitle).font(.system(size: 16, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 24, weight: .bold, design: .rounded)).appKerning(24)
                .foregroundStyle(.white).padding(.top, 6)
            Text(L.profileCorrectAnswersProgress(done, total))
                .font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(.white.opacity(0.85)).padding(.top, 4)
            HStack {
                Text(L.profileLevelLearner).font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(.white)
                Spacer()
                Text(L.profileLevelExpert).font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(.white)
            }.padding(.top, 24)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white).frame(height: 10)
                    Capsule().fill(AppColor.brandBlue).frame(width: geo.size.width * ratio, height: 10)
                        .padding(2)
                }
            }
            .frame(height: 12).padding(.top, 6)
        }
        .padding(22)
        .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: Notifications

    private var notificationsCard: some View {
        VStack(spacing: 0) {
            settingsRow(L.profileNotifications, isOn: Binding(
                get: { session.notificationsEnabled },
                set: { on in session.notificationsEnabled = on
                    if on { Task { _ = await PushService.shared.requestAuthorization() } } else { PushService.shared.disable() } }))
            Divider().overlay(Color(hex: "#DDDDDD"))
            settingsRow(L.profileHaptics, isOn: $session.hapticsEnabled)
            Divider().overlay(Color(hex: "#DDDDDD"))
            settingsRow(L.profileSound, isOn: $session.soundEnabled)
        }
        .padding(.horizontal, 20).padding(.vertical, 4)
        .background(Color(hex: "#F5F5F5"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func settingsRow(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(AppColor.textBlack)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(AppColor.brandBlue).scaleEffect(0.85)
        }
        .padding(.vertical, 12)
    }

    // MARK: Menu

    private var menuCard: some View {
        VStack(spacing: 0) {
            menuRow(L.premium) { showPaywall = true }
            menuDivider
            menuRow(L.favoritesTitle) { path.append(ProfileRoute.favorites) }
            menuDivider
            menuRow(L.editProfile) { path.append(ProfileRoute.edit) }
            menuDivider
            menuRow(L.selectLanguage) { showLanguage = true }
            menuDivider
            menuRow(L.privacyPolicy) { }
            menuDivider
            menuRow(L.termsOfUse) { }
            menuDivider
            HStack {
                Text(L.animationsToggle).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(AppColor.textBlack)
                    .padding(.leading, 12)
                Spacer()
                Toggle("", isOn: $session.animationsEnabled).labelsHidden().tint(AppColor.brandBlue).scaleEffect(0.85)
            }.padding(.vertical, 10)
            menuDivider
            menuRow(L.rateApp) { requestReview() }
            menuDivider
            ShareLink(item: URL(string: "https://apps.apple.com/app/id000000000")!) {
                menuRowLabel(L.shareApp)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(Color(hex: "#F5F5F5"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func menuRow(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { menuRowLabel(text) }.buttonStyle(.plain)
    }
    private func menuRowLabel(_ text: String) -> some View {
        HStack {
            Text(text).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(AppColor.textBlack)
                .padding(.leading, 12)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Color(hex: "#4573F1")).font(.system(size: 16))
        }
        .padding(.vertical, 16).contentShape(Rectangle())
    }
    private var menuDivider: some View { Rectangle().fill(Color(hex: "#DDDDDD")).frame(height: 1) }

    // MARK: Support / logout

    private var supportButton: some View {
        Button { } label: {
            HStack(spacing: 12) {
                Image("support").resizable().scaledToFit().frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.supportTitle).font(.system(size: 16, weight: .medium, design: .rounded)).foregroundStyle(.white)
                    Text(L.supportSubtitle).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.white).font(.system(size: 22))
            }
            .padding(.init(top: 22, leading: 22, bottom: 22, trailing: 16))
            .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }.buttonStyle(.plain)
    }

    private var logoutButton: some View {
        Button { confirmLogout = true } label: {
            HStack(spacing: 12) {
                Image("logout").renderingMode(.template).resizable().scaledToFit().frame(width: 20, height: 20)
                    .foregroundStyle(Color(hex: "#C84949"))
                Text(L.logoutTitle).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(Color(hex: "#C84949"))
                Spacer()
            }
            .padding(24)
            .background(Color(hex: "#FFE4E4"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }.buttonStyle(.plain)
    }
}
