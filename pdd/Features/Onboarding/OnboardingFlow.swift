//
//  OnboardingFlow.swift
//  pdd
//
//  Splash → carousel → survey → social auth → loading → social proof (spec §8),
//  matched to the Flutter screens.
//

import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var app
    @State private var step: Step = {
        #if DEBUG
        let s = UserDefaults.standard.integer(forKey: "debug_onb_step")
        return [Step.carousel, .survey, .auth, .loading, .socialProof][min(s, 4)]
        #else
        return .carousel
        #endif
    }()

    enum Step { case carousel, survey, auth, loading, socialProof }

    var body: some View {
        ZStack {
            switch step {
            case .carousel:    CarouselView { step = .survey }
            case .survey:      SurveyView(onBack: { step = .carousel }) { step = .auth }
            case .auth:        SocialAuthView { step = .loading }
            case .loading:     LoadingView { step = .socialProof }
            case .socialProof: SocialProofView { app.completeOnboarding() }
            }
        }
    }
}

// MARK: - Carousel

private struct CarouselView: View {
    var onDone: () -> Void
    @State private var page = 0
    private let slides = L.onboardingSlides

    var body: some View {
        ZStack {
            AppColor.brandBlue.ignoresSafeArea()
            VStack(spacing: 0) {
                Image("go_icon").resizable().scaledToFit().frame(height: 70).padding(.top, 20)
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                        VStack(spacing: 0) {
                            Spacer()
                            Image(slide.img).resizable().scaledToFit().frame(height: 290)
                            Text(slide.title)
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white).multilineTextAlignment(.center).lineSpacing(1)
                                .padding(.top, 40)
                            Text(slide.subtitle)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundStyle(.white).multilineTextAlignment(.center).padding(.top, 16)
                            Spacer()
                        }
                        .padding(24).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule().fill(.white.opacity(page == i ? 1 : 0.3)).frame(width: 6, height: 6)
                    }
                }.padding(.bottom, 22)
                Button {
                    if page < slides.count - 1 { withAnimation { page += 1 } } else { onDone() }
                } label: {
                    Text(page < slides.count - 1 ? L.onboardingNext : L.onboardingStart)
                        .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(AppColor.brandBlue)
                        .frame(maxWidth: .infinity).frame(height: 76).background(.white, in: Capsule())
                }
                .buttonStyle(.plain).padding(.horizontal, 30).padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Survey

private struct SurveyView: View {
    var onBack: () -> Void
    var onDone: () -> Void

    @State private var q = 0
    @State private var answers: [Int: String] = [:]
    @State private var search = ""

    private var progress: Double { [0.33, 0.66, 1.0][q] }
    private var selected: String? { answers[q] }
    private var isLast: Bool { q == 2 }

    var body: some View {
        VStack(spacing: 0) {
            appBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    switch q {
                    case 0: vehicleStep
                    case 1: regionStep
                    default: knowledgeStep
                    }
                }
                .padding(.bottom, 16)
            }
            bottomButton
        }
        .background(.white)
    }

    private var appBar: some View {
        VStack(spacing: 0) {
            Image("GoB").resizable().scaledToFit().frame(height: 46).padding(.top, 8)
            HStack(spacing: 12) {
                Button(action: back) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(AppColor.brandBlue)
                }.buttonStyle(.plain)
                ProgressView(value: progress)
                    .tint(AppColor.brandBlue).background(AppColor.brandBlue.opacity(0.2))
                    .padding(.trailing, 18)
            }
            .padding(.leading, 20).padding(.vertical, 8)
        }
        .background(.white)
    }

    private func title(_ t: String) -> some View {
        Text(t).font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(AppColor.textBlack).lineSpacing(4)
    }

    private var vehicleStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            title(L.surveyVehicleQuestion).padding(.bottom, 30)
            ForEach(L.surveyVehicleOptions, id: \.id) { opt in
                cardRow(id: opt.id, icon: opt.icon, title: opt.title, subtitle: opt.subtitle)
            }
        }
        .padding(.horizontal, 24).padding(.top, 24)
    }

    private var regionStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            title(L.surveyRegionQuestion).padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 12)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(AppColor.greyText)
                TextField(L.surveyRegionSearchHint, text: $search).font(.system(size: 16, design: .rounded))
            }
            .padding(.horizontal, 16).frame(height: 48)
            .background(Color(hex: "#F5F5F5"), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24).padding(.bottom, 12)
            ForEach(L.surveyRegions.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }, id: \.self) { r in
                plainRow(id: r, title: r)
            }
        }
    }

    private var knowledgeStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            title(L.surveyKnowledgeQuestion).padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 12)
            ForEach(L.surveyKnowledgeOptions, id: \.self) { o in plainRow(id: o, title: o) }
        }
    }

    private func cardRow(id: String, icon: String, title: String, subtitle: String) -> some View {
        let on = selected == id
        return Button { answers[q] = id } label: {
            HStack(spacing: 16) {
                Image(icon).resizable().scaledToFit().frame(width: 48, height: 48)
                    .background(AppColor.lightBg, in: Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                    Text(subtitle).font(.system(size: 13, design: .rounded)).foregroundStyle(AppColor.greyText)
                }
                Spacer()
                indicator(on: on)
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(on ? AppColor.brandBlue : .clear, lineWidth: 2))
            .padding(.bottom, 12)
        }.buttonStyle(.plain)
    }

    private func plainRow(id: String, title: String) -> some View {
        let on = selected == id
        return VStack(spacing: 0) {
            Button { answers[q] = id } label: {
                HStack {
                    Text(title).font(.system(size: 16, design: .rounded)).foregroundStyle(AppColor.textBlack)
                    Spacer()
                    indicator(on: on)
                }
                .padding(.init(top: 18, leading: 24, bottom: 24, trailing: 24))
                .contentShape(Rectangle())
            }.buttonStyle(.plain)
            Rectangle().fill(Color(hex: "#E1E1E1")).frame(height: 1).padding(.horizontal, 30)
        }
    }

    private func indicator(on: Bool) -> some View {
        Group {
            if on { Image("Select").resizable().scaledToFit().frame(width: 22, height: 22).clipShape(Circle()) }
            else { Circle().stroke(Color(hex: "#DDDDDD"), lineWidth: 1.8).frame(width: 22, height: 22) }
        }
    }

    private var bottomButton: some View {
        Button(action: next) {
            HStack(spacing: 8) {
                Text(isLast ? L.surveyFinish : L.surveyNext).font(.system(size: 16, weight: .semibold, design: .rounded))
                if !isLast { Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)) }
            }
            .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 70)
            .background(AppColor.brandBlue.opacity(selected == nil ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 35, style: .continuous))
        }
        .buttonStyle(.plain).disabled(selected == nil)
        .padding(.horizontal, 30).padding(.bottom, 16)
    }

    private func next() {
        guard selected != nil else { return }
        if isLast { onDone() } else { search = ""; withAnimation { q += 1 } }
    }
    private func back() {
        if q == 0 { onBack() } else { search = ""; withAnimation { q -= 1 } }
    }
}

// MARK: - Social auth

private struct SocialAuthView: View {
    var onDone: () -> Void
    @State private var busy = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("ai_akzhol").resizable().scaledToFit().frame(maxHeight: 240)
            Text("Создай аккаунт").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(AppColor.textBlack)
            Text("Чтобы сохранять прогресс и результаты")
                .font(.system(size: 15, design: .rounded)).foregroundStyle(AppColor.greyText).multilineTextAlignment(.center)
            Spacer()
            authButton("Продолжить с Apple", icon: "apple.logo", bg: .black, fg: .white) { signIn(.apple) }
            authButton("Продолжить с Google", asset: "google_g_logo", bg: AppColor.lightBg, fg: AppColor.textBlack) { signIn(.google) }
            Button("Продолжить как гость") { signIn(.demo) }
                .font(.system(size: 15, weight: .medium, design: .rounded)).foregroundStyle(AppColor.greyText).padding(.top, 4)
        }
        .padding(.horizontal, 24).padding(.bottom, 16).background(.white).disabled(busy)
    }

    private func authButton(_ title: String, icon: String? = nil, asset: String? = nil, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).font(.system(size: 18)) }
                if let asset { Image(asset).resizable().scaledToFit().frame(width: 20, height: 20) }
                Text(title).font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(fg).frame(maxWidth: .infinity).frame(height: 56).background(bg, in: Capsule())
        }.buttonStyle(.plain)
    }

    private func signIn(_ provider: AuthProvider) {
        busy = true
        Task { @MainActor in
            if let info = try? await LocalAuthService.shared.signIn(with: provider) { Session.shared.update(user: info) }
            busy = false; onDone()
        }
    }
}

// MARK: - Loading

private struct LoadingView: View {
    var onDone: () -> Void
    @State private var percent: Double = 0
    @State private var text = L.loadingStart

    var body: some View {
        VStack(spacing: 0) {
            Image("GoB").resizable().scaledToFit().frame(height: 60).padding(.top, 30).padding(.bottom, 50)
            Spacer().frame(height: 65)
            ZStack {
                Circle().stroke(AppColor.brandBlue.opacity(0.1), lineWidth: 5).frame(width: 240, height: 240)
                Circle().trim(from: 0, to: percent)
                    .stroke(AppColor.brandBlue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 240, height: 240).animation(.easeInOut(duration: 1.8), value: percent)
                Text("\(Int(percent * 100))%").font(.system(size: 64, weight: .bold, design: .rounded)).foregroundStyle(AppColor.brandBlue)
            }
            Spacer().frame(height: 50)
            Text(text).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                .multilineTextAlignment(.center).animation(.easeInOut, value: text)
            Spacer()
        }
        .frame(maxWidth: .infinity).background(.white)
        .task { await run() }
    }

    private func run() async {
        for step in L.loadingSteps {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { percent = step.end; text = step.text }
        }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        withAnimation { percent = 1.0 }
        try? await Task.sleep(nanoseconds: 800_000_000)
        onDone()
    }
}

// MARK: - Social proof

private struct SocialProofView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("GoB").resizable().scaledToFit().frame(height: 34).padding(.vertical, 16)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    hero
                    statsRow.padding(.top, 20)
                    VStack(spacing: 12) {
                        ForEach(Array(L.socialProofFeatures.enumerated()), id: \.offset) { _, f in featureTile(f) }
                    }.padding(.top, 28)
                    Text(L.socialProofReviewsTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                        .padding(.top, 32).padding(.bottom, 16)
                    VStack(spacing: 14) {
                        ForEach(Array(L.socialProofReviews.enumerated()), id: \.offset) { _, r in reviewCard(r) }
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 8)
            }
            Button(action: onContinue) {
                Text(L.socialProofContinue).font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 58)
                    .background(AppColor.brandBlue, in: RoundedRectangle(cornerRadius: 35, style: .continuous))
            }
            .buttonStyle(.plain).padding(.horizontal, 20).padding(.vertical, 12)
        }
        .background(.white)
    }

    private var hero: some View {
        (Text(L.socialProofHero1).foregroundColor(AppColor.textBlack)
         + Text(L.socialProofHero2).foregroundColor(AppColor.brandBlue)
         + Text(L.socialProofHero3).foregroundColor(AppColor.textBlack))
            .font(.system(size: 26, weight: .heavy, design: .rounded)).lineSpacing(4)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(L.socialProofStats.enumerated()), id: \.offset) { i, s in
                VStack(spacing: 4) {
                    Text(s.value).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(AppColor.brandBlue)
                    Text(s.label).font(.system(size: 12, design: .rounded)).foregroundStyle(Color(hex: "#B6B6B6"))
                        .multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity)
                if i < L.socialProofStats.count - 1 { Rectangle().fill(Color(hex: "#DDDDDD")).frame(width: 1, height: 36) }
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 16)
        .background(Color(hex: "#F5F5F5"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func featureTile(_ f: (icon: String, color: String, title: String, subtitle: String)) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color(hex: f.color).opacity(0.12)).frame(width: 44, height: 44)
                if f.icon.isEmpty {
                    Image("ai_akzhol").resizable().scaledToFit().frame(width: 28, height: 28)
                } else {
                    Image(systemName: f.icon).font(.system(size: 22)).foregroundStyle(Color(hex: f.color))
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(f.title).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(AppColor.textBlack).lineSpacing(2)
                Text(f.subtitle).font(.system(size: 12, design: .rounded)).foregroundStyle(Color(hex: "#B6B6B6")).lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
    }

    private func reviewCard(_ r: (name: String, date: String, text: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(String(r.name.prefix(1))).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    .frame(width: 38, height: 38).background(AppColor.brandBlue, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(r.name).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                    HStack(spacing: 1) {
                        ForEach(0..<5, id: \.self) { _ in Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(Color(hex: "#FFCC00")) }
                    }
                }
                Spacer()
                Text(r.date).font(.system(size: 12, design: .rounded)).foregroundStyle(Color(hex: "#B6B6B6"))
            }
            Text(r.text).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(Color(hex: "#4D4D4D")).lineSpacing(4)
        }
        .padding(16)
        .background(Color(hex: "#F5F5F5"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
