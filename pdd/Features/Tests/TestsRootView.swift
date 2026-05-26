//
//  TestsRootView.swift
//  pdd
//
//  Tests tab: trial exam, work-on-mistakes, and history (8 preview / all).
//

import SwiftUI

enum TrialKind: Hashable { case standard, individual
    var config: QuizConfig { self == .standard ? .trialStandard() : .trialIndividual() }
}
enum TestsRoute: Hashable { case intro(TrialKind), history }

struct TestsRootView: View {
    @State private var path = NavigationPath()
    @State private var launch: QuizConfig?
    @State private var mistakes = MistakesBank.shared
    @State private var history = TestHistory.shared

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Тесты").font(.app(28, .bold)).foregroundStyle(AppColor.textBlack)
                        .padding(.horizontal, AppLayout.homeMargin).padding(.top, 8)

                    trialCard(
                        icon: { Image("KZ").resizable().scaledToFit().padding(12) },
                        title: "Пробное тестирование",
                        subtitle: "40 вопросов · порог сдачи 32",
                        action: { path.append(TestsRoute.intro(.standard)) }
                    )

                    trialCard(
                        icon: { Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24)).foregroundStyle(.white) },
                        title: "Работа над ошибками",
                        subtitle: mistakes.isEmpty ? "Банк ошибок пуст" : "\(mistakes.count) вопросов в банке ошибок",
                        enabled: !mistakes.isEmpty,
                        action: { path.append(TestsRoute.intro(.individual)) }
                    )

                    historySection
                }
                .padding(.bottom, 24)
            }
            .background(.white)
            .navigationDestination(for: TestsRoute.self) { route in
                switch route {
                case .intro(let kind):
                    TrialIntroView(kind: kind) { launch = kind.config }
                case .history:
                    HistoryListView { launch = .replay($0) }
                }
            }
            .quizFlow(item: $launch)
        }
    }

    // MARK: Cards

    private func trialCard<Icon: View>(@ViewBuilder icon: () -> Icon, title: String,
                                       subtitle: String, enabled: Bool = true,
                                       action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack { Circle().fill(AppColor.brandBlue2).frame(width: 56, height: 56); icon().frame(width: 56, height: 56) }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.app(16, .semibold)).foregroundStyle(AppColor.textBlack)
                    Text(subtitle).font(.app(13)).foregroundStyle(AppColor.greyText)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.tabInactive)
            }
            .padding(18)
            .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.cardBorder, lineWidth: 1))
            .opacity(enabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .padding(.horizontal, AppLayout.homeMargin)
    }

    @ViewBuilder private var historySection: some View {
        if !history.entries.isEmpty {
            HStack {
                Text("История тестов").font(.app(20, .semibold)).foregroundStyle(AppColor.textBlack)
                Spacer()
                if history.entries.count > QuizRules.historyPreviewCount {
                    Button("Показать все") { path.append(TestsRoute.history) }
                        .font(.app(14, .medium)).foregroundStyle(AppColor.brandBlue)
                }
            }
            .padding(.horizontal, AppLayout.homeMargin).padding(.top, 8)

            VStack(spacing: 10) {
                ForEach(history.preview) { entry in
                    HistoryRow(entry: entry) { launch = .replay(entry) }
                }
            }
            .padding(.horizontal, AppLayout.homeMargin)
        }
    }
}

struct HistoryRow: View {
    let entry: TestHistoryEntry
    var onReplay: () -> Void

    var body: some View {
        Button(action: onReplay) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill((entry.passed ? AppColor.greenSuccess : AppColor.redError).opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: entry.passed ? "checkmark" : "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(entry.passed ? AppColor.greenSuccess : AppColor.redError)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.quizModuleId == TrialExam.individual ? "Индивидуальное тестирование" : "Пробное тестирование")
                        .font(.app(15, .medium)).foregroundStyle(AppColor.textBlack)
                    Text(entry.completedDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.app(12)).foregroundStyle(AppColor.greyText)
                }
                Spacer()
                Text("\(entry.score)/\(entry.total)")
                    .font(.app(16, .bold))
                    .foregroundStyle(entry.passed ? AppColor.brandBlue : AppColor.redError)
            }
            .padding(14)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!entry.canReplay)
    }
}

struct HistoryListView: View {
    var onReplay: (TestHistoryEntry) -> Void
    @State private var history = TestHistory.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(history.entries) { entry in
                    HistoryRow(entry: entry) { onReplay(entry) }
                }
            }
            .padding(.horizontal, AppLayout.homeMargin)
            .padding(.vertical, 12)
        }
        .background(.white)
        .navigationTitle("История тестов")
        .navigationBarTitleDisplayMode(.inline)
    }
}
