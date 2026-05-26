//
//  MainTabView.swift
//  pdd
//
//  Custom four-tab shell (Курс / Тесты / Акжол / Профиль), default Тесты.
//

import SwiftUI

enum PDDTab: Int, CaseIterable, Identifiable {
    case home, tests, akzhol, profile
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: "Курс"
        case .tests: "Тесты"
        case .akzhol: "Акжол"
        case .profile: "Профиль"
        }
    }
    var symbol: String {
        switch self {
        case .home: "graduationcap.fill"
        case .tests: "book.fill"
        case .akzhol: "waveform"
        case .profile: "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var app = AppState.shared

    var body: some View {
        Group {
            switch app.selectedTab {
            case .home:    HomeRootView()
            case .tests:   TestsRootView()
            case .akzhol:  AkzholRootView()
            case .profile: ProfileRootView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PDDTabBar(selected: $app.selectedTab)
        }
    }
}

struct PDDTabBar: View {
    @Binding var selected: PDDTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PDDTab.allCases) { tab in
                Button {
                    Haptics.impact()
                    selected = tab
                } label: {
                    VStack(spacing: 6) {
                        glyph(tab).frame(width: 28, height: 28)
                        Text(tab.title).font(.app(12, .medium)).tracking(-0.36)
                    }
                    .foregroundStyle(selected == tab ? AppColor.brandBlue : AppColor.tabInactive)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                .fill(.white)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                        .stroke(AppColor.navBorder, lineWidth: 1)
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    @ViewBuilder private func glyph(_ tab: PDDTab) -> some View {
        if tab == .akzhol {
            VoiceChatGlyph()
        } else {
            Image(systemName: tab.symbol).font(.system(size: 23, weight: .medium))
        }
    }
}
