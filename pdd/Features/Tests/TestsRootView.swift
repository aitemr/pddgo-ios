//
//  TestsRootView.swift
//  pdd
//
//  Tests tab — faithful port of testPage.dart (TestMainPage).
//

import SwiftUI

enum TrialKind: Hashable {
    case standard, individual
    var moduleId: String { self == .standard ? TrialExam.standard : TrialExam.individual }
}

enum TestsRoute: Hashable {
    case detail(TrialKind)
    case historyAll
    case roadSign
}

struct TestsRootView: View {
    var onSwitchTab: (PDDTab) -> Void = { _ in }

    @State private var path = NavigationPath()
    @State private var launch: QuizConfig?
    @State private var history = TestHistory.shared

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    roadSignPromo.padding(.init(top: 24, leading: 16, bottom: 0, trailing: 16))
                    Spacer().frame(height: 24)
                    individualCard
                    historySection.padding(.init(top: 32, leading: 30, bottom: 0, trailing: 30))
                }
                .padding(.bottom, 60)
            }
            .background(.white)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: TestsRoute.self) { route in
                switch route {
                case .detail(let kind): TestDetailView(kind: kind) { startQuiz(kind) }
                case .historyAll: TestHistoryFullView { launch = .replay($0) }
                case .roadSign: RoadSignChatView()
                }
            }
            .quizFlow(item: $launch)
        }
        #if DEBUG
        .onAppear {
            if UserDefaults.standard.bool(forKey: "debug_autoquiz") && launch == nil {
                launch = .trialStandard()
            }
        }
        #endif
    }

    private func startQuiz(_ kind: TrialKind) {
        if kind == .individual && MistakesBank.shared.isEmpty { return }
        launch = kind == .standard ? .trialStandard() : .trialIndividual()
    }

    // MARK: Blue header

    private var header: some View {
        VStack(spacing: 0) {
            Image("GoW").resizable().scaledToFit().frame(width: 70, height: 70)
                .padding(.top, 12)
            Image("KZ").resizable().scaledToFit().frame(width: 80, height: 80).padding(.top, 22)
            Text(L.testMainTitle)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .appKerning(36)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.top, 16)
            Button { path.append(TestsRoute.detail(.standard)) } label: {
                HStack(spacing: 8) {
                    Text(L.testStartTrialBtn)
                        .font(.system(size: 16, weight: .bold, design: .rounded)).appKerning(16)
                        .multilineTextAlignment(.center)
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(AppColor.brandBlue)
                .frame(maxWidth: .infinity).frame(height: 70)
                .background(.white, in: Capsule())
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 46).padding(.top, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, safeTop + 12)
        .padding(.bottom, 30)
        .background(
            ZStack {
                AppColor.brandBlue
                Image("flagBack").resizable().scaledToFill()
            }
        )
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
    }

    private var safeTop: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 47
    }

    // MARK: Road-sign promo

    private var roadSignPromo: some View {
        Button { path.append(TestsRoute.roadSign) } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L.roadsignDetector)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white).lineSpacing(2)
                    HStack(spacing: 4) {
                        Text(L.go).font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline().foregroundStyle(.white.opacity(0.7))
                        Image(systemName: "arrow.right").font(.system(size: 14)).foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer(minLength: 0)
                Image("containerLogo").resizable().scaledToFit().frame(width: 130, height: 110)
            }
            .padding(.init(top: 20, leading: 20, bottom: 20, trailing: 0))
            .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: Individual / work-on-mistakes card

    private var individualCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Image("info").resizable().scaledToFit().frame(height: 35).frame(maxWidth: 35, alignment: .leading)
                Text(L.workOnMistakesShort)
                    .font(.system(size: 26, weight: .bold, design: .rounded)).appKerning(26)
                    .foregroundStyle(AppColor.textBlack).padding(.top, 24)
                Text(L.individualTestingAiDesc)
                    .font(.system(size: 14, design: .rounded)).appKerning(14)
                    .foregroundStyle(AppColor.textBlack).lineSpacing(3).padding(.top, 12)
                blueButton(L.startTestingBtn, height: 70) { path.append(TestsRoute.detail(.individual)) }
                    .padding(.top, 24)
            }
            .padding(.init(top: 24, leading: 20, bottom: 24, trailing: 20))
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 30)

            Text(L.recommended)
                .font(.system(size: 12, weight: .heavy, design: .rounded)).appKerning(12)
                .foregroundStyle(.white)
                .frame(width: 133, height: 28)
                .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppColor.brandBlue.opacity(0.3), radius: 8, y: 4)
                .padding(.trailing, 80).offset(y: -10)
        }
    }

    // MARK: History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(L.testHistoryTitle)
                    .font(.system(size: 18, weight: .heavy, design: .rounded)).appKerning(18)
                    .foregroundStyle(AppColor.textBlack)
                Spacer()
                if history.entries.count > QuizRules.historyPreviewCount {
                    Button(L.testHistoryShowAll) { path.append(TestsRoute.historyAll) }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.brandBlue)
                }
            }
            Text(L.testHistorySubtitle)
                .font(.system(size: 14, design: .rounded)).appKerning(14)
                .foregroundStyle(AppColor.greyText).lineSpacing(2).padding(.top, 4)

            if history.entries.isEmpty {
                Text(L.testHistoryEmpty)
                    .font(.system(size: 14, design: .rounded)).appKerning(14)
                    .foregroundStyle(AppColor.greyText).lineSpacing(2)
                    .padding(.top, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(history.preview) { e in
                        TestHistoryRow(entry: e) { launch = .replay(e) }
                    }
                }
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Shared blue pill button

func blueButton(_ title: String, height: CGFloat = 60, action: @escaping () -> Void) -> some View {
    Button { Haptics.impact(); action() } label: {
        HStack(spacing: 8) {
            Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).appKerning(16)
            Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity).frame(height: height)
        .background(AppColor.brandBlue, in: Capsule())
    }
    .buttonStyle(.plain)
}

// MARK: - History row

struct TestHistoryRow: View {
    let entry: TestHistoryEntry
    var onTap: () -> Void

    private var isKz: Bool { entry.quizModuleId == TrialExam.standard }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(isKz ? "flag" : "Library").resizable().scaledToFill()
                    .frame(width: 40, height: 40).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(isKz ? L.trialTestingShort : L.workOnMistakesShort)
                        .font(.system(size: 14, weight: .bold, design: .rounded)).appKerning(14)
                        .foregroundStyle(AppColor.textBlack)
                    Text(L.testHistoryRowSubtitle(entry.score, entry.total, formatDate(entry.completedDate)))
                        .font(.system(size: 12, design: .rounded)).appKerning(12)
                        .foregroundStyle(AppColor.greyText)
                }
                Spacer()
                Image(systemName: entry.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(entry.passed ? Color(hex: "#34C759") : Color(hex: "#E53935"))
            }
            .padding(.horizontal, 16).frame(height: 68)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!entry.canReplay)
    }

    private func formatDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd.MM.yyyy"; return f.string(from: d)
    }
}

struct TestHistoryFullView: View {
    var onReplay: (TestHistoryEntry) -> Void
    @State private var history = TestHistory.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(history.entries) { e in
                    TestHistoryRow(entry: e) { onReplay(e) }
                }
            }
            .padding(.init(top: 20, leading: 30, bottom: 60, trailing: 30))
        }
        .background(.white)
        .navigationTitle(L.testHistoryFullTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
