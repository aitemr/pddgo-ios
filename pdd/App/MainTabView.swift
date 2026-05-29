//
//  MainTabView.swift
//  pdd
//
//  Custom three-tab shell (Тесты / Акжол / Профиль), default Тесты — matches
//  the Flutter BottomNavBar (Home page exists but is not shown in the bar).
//

import SwiftUI

enum PDDTab: Int, CaseIterable, Identifiable {
    case tests, akzhol, profile
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .tests: L.navTests
        case .akzhol: L.navAkzhol
        case .profile: L.navProfile
        }
    }
    var icon: String {
        switch self {
        case .tests: "nav_tests"
        case .akzhol: "nav_akzhol"
        case .profile: "nav_profile"
        }
    }
}

struct MainTabView: View {
    @State private var app = AppState.shared

    var body: some View {
        Group {
            switch app.selectedTab {
            case .tests:   TestsRootView(onSwitchTab: { app.selectedTab = $0 })
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

    private let active = AppColor.brandBlue          // #1B8FEF
    private let inactive = AppColor.tabInactive      // #AAAAAA

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PDDTab.allCases) { tab in
                let on = selected == tab
                Button {
                    Haptics.impact()
                    selected = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(tab.icon)
                            .renderingMode(.template)
                            .resizable().scaledToFit()
                            .frame(width: 28, height: 28)
                        Text(tab.title)
                            .font(.system(size: 12, weight: on ? .semibold : .regular, design: .rounded))
                    }
                    .foregroundStyle(on ? active : inactive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(on ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(.white)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .stroke(AppColor.cardBorder, lineWidth: 1)
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
