//
//  OnboardingFlow.swift
//  pdd
//
//  Splash → carousel → survey → social auth → loading → social proof (spec §8).
//

import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var app
    @State private var step: Step = .carousel

    enum Step { case carousel, survey, auth, loading, socialProof }

    var body: some View {
        ZStack {
            switch step {
            case .carousel:    CarouselView { step = .survey }
            case .survey:      SurveyView { step = .auth }
            case .auth:        SocialAuthView { step = .loading }
            case .loading:     LoadingView { step = .socialProof }
            case .socialProof: SocialProofView { app.completeOnboarding() }
            }
        }
        .animation(.easeInOut(duration: 0.26), value: stepKey)
    }
    private var stepKey: Int {
        switch step { case .carousel: 0; case .survey: 1; case .auth: 2; case .loading: 3; case .socialProof: 4 }
    }
}

// MARK: - Carousel

private struct CarouselView: View {
    var onDone: () -> Void
    @State private var page = 0
    private let slides: [(image: String, title: String, subtitle: String)] = [
        ("driving_student", "Начни свой путь\nк водительскому удостоверению!", "Проходи видео-курс и выполняй задания"),
        ("materialsRoad", "Проверь свои знания —\nпроходи пробные тесты\nпрямо в приложении", "Реальные экзаменационные вопросы"),
        ("ai_akzhol", "ГАИшник Асылхан — твой\nличный помощник по ПДД", "Отвечает на вопросы и помогает готовиться к экзамену"),
        ("exampleVideo", "Понятные объяснения\nс наглядными анимациями\nи примерами", "Учись легко и эффективно"),
    ]

    var body: some View {
        ZStack {
            AppColor.brandBlue.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("GO").font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFE000")).padding(.top, 20)
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                        VStack(spacing: 24) {
                            Image(slide.image).resizable().scaledToFit()
                                .frame(maxHeight: 320)
                                .padding(24)
                                .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .padding(.horizontal, AppLayout.onboardingMargin)
                            VStack(spacing: 10) {
                                Text(slide.title).font(.app(26, .bold)).foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                Text(slide.subtitle).font(.app(15)).foregroundStyle(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, AppLayout.onboardingMargin)
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if page < slides.count - 1 { page += 1 } else { onDone() }
                } label: {
                    Text(page < slides.count - 1 ? "Далее" : "Начать")
                        .font(.app(18, .bold)).foregroundStyle(AppColor.brandBlue)
                        .frame(maxWidth: .infinity).frame(height: 64)
                        .background(.white, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppLayout.onboardingMargin).padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Survey

private struct SurveyView: View {
    var onDone: () -> Void
    @State private var q = 0
    @State private var vehicle: String?
    @State private var region: String?
    @State private var level: String?
    @State private var search = ""

    private let vehicles = [("Car", "Легковой автомобиль"), ("Truck", "Грузовой автомобиль"), ("Bike", "Мотоцикл")]
    private let levels = ["Я только начинаю", "Уже немного знаю правила", "Хочу проверить знания перед экзаменом"]
    private let regions = ["Алматы", "Астана", "Шымкент", "Караганда", "Актобе", "Тараз", "Павлодар",
                           "Усть-Каменогорск", "Семей", "Атырау", "Костанай", "Кызылорда", "Уральск",
                           "Петропавловск", "Актау", "Темиртау", "Туркестан", "Кокшетау", "Талдыкорган",
                           "Экибастуз", "Рудный", "Жезказган", "Балхаш", "Кентау"]

    private var canProceed: Bool {
        switch q { case 0: vehicle != nil; case 1: region != nil; default: level != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("GO").font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColor.brandBlue).frame(maxWidth: .infinity).padding(.top, 12)

            HStack(spacing: 8) {
                BackButton { if q > 0 { q -= 1 } }
                ProgressView(value: Double(q + 1), total: 3).tint(AppColor.brandBlue)
            }
            .padding(.horizontal, AppLayout.onboardingMargin).padding(.vertical, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    switch q {
                    case 0: questionBlock("С каким транспортом\nты готовишься?") {
                        ForEach(vehicles, id: \.0) { v in
                            optionRow(title: v.1, icon: v.0, selected: vehicle == v.0) { vehicle = v.0 }
                        }
                    }
                    case 1: regionQuestion
                    default: questionBlock("С чего начнём твой\nпуть к правам?") {
                        ForEach(levels, id: \.self) { l in
                            optionRow(title: l, icon: nil, selected: level == l) { level = l }
                        }
                    }
                    }
                }
                .padding(.horizontal, AppLayout.onboardingMargin).padding(.top, 8)
            }

            PrimaryButton(title: q < 2 ? "Следующий вопрос" : "Завершить", enabled: canProceed) {
                if q < 2 { q += 1 } else { onDone() }
            }
            .padding(.horizontal, AppLayout.onboardingMargin).padding(.bottom, 16)
        }
        .background(.white)
    }

    @ViewBuilder private func questionBlock<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        Text(title).font(.app(26, .bold)).foregroundStyle(AppColor.textBlack)
        content()
    }

    private var regionQuestion: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Из какого ты региона?").font(.app(26, .bold)).foregroundStyle(AppColor.textBlack)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(AppColor.greyText)
                TextField("Поиск", text: $search).font(.app(16))
            }
            .padding(.horizontal, 14).frame(height: 48)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 12))
            ForEach(regions.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }, id: \.self) { r in
                optionRow(title: r, icon: nil, selected: region == r) { region = r }
            }
        }
    }

    private func optionRow(title: String, icon: String?, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let icon { Image(icon).resizable().scaledToFit().frame(width: 32, height: 32) }
                Text(title).font(.app(16, .medium)).foregroundStyle(AppColor.textBlack)
                Spacer()
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? AppColor.brandBlue : AppColor.tabInactive)
            }
            .padding(.horizontal, 16).frame(height: 60)
            .background(selected ? AppColor.brandBlue.opacity(0.06) : AppColor.lightBg,
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(selected ? AppColor.brandBlue : .clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
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
            Text("Создай аккаунт").font(.app(28, .bold)).foregroundStyle(AppColor.textBlack)
            Text("Чтобы сохранять прогресс и результаты")
                .font(.app(15)).foregroundStyle(AppColor.greyText).multilineTextAlignment(.center)
            Spacer()
            authButton("Продолжить с Apple", icon: "apple.logo", bg: .black, fg: .white) { signIn(.apple) }
            authButton("Продолжить с Google", asset: "google_g_logo", bg: AppColor.lightBg, fg: AppColor.textBlack) { signIn(.google) }
            Button("Продолжить как гость") { signIn(.demo) }
                .font(.app(15, .medium)).foregroundStyle(AppColor.greyText).padding(.top, 4)
        }
        .padding(.horizontal, AppLayout.onboardingMargin).padding(.bottom, 16)
        .background(.white)
        .disabled(busy)
    }

    private func authButton(_ title: String, icon: String? = nil, asset: String? = nil,
                            bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).font(.system(size: 18)) }
                if let asset { Image(asset).resizable().scaledToFit().frame(width: 20, height: 20) }
                Text(title).font(.app(16, .semibold))
            }
            .foregroundStyle(fg).frame(maxWidth: .infinity).frame(height: 56)
            .background(bg, in: Capsule())
        }.buttonStyle(.plain)
    }

    private func signIn(_ provider: AuthProvider) {
        busy = true
        Task { @MainActor in
            if let info = try? await LocalAuthService.shared.signIn(with: provider) {
                Session.shared.update(user: info)
            }
            busy = false
            onDone()
        }
    }
}

// MARK: - Loading

private struct LoadingView: View {
    var onDone: () -> Void
    @State private var percent = 0
    private let steps = [(30, "Собираем ваши ответы…"), (75, "Готовим план обучения…"), (99, "Анализируем ваш результат…"), (100, "Готово!")]
    @State private var stepIdx = 0

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            ZStack {
                Circle().stroke(AppColor.brandBlue.opacity(0.15), lineWidth: 10).frame(width: 220, height: 220)
                Circle().trim(from: 0, to: CGFloat(percent) / 100)
                    .stroke(AppColor.brandBlue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 220, height: 220)
                    .animation(.easeInOut, value: percent)
                Text("\(percent)%").font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.brandBlue)
            }
            Text(steps[min(stepIdx, steps.count - 1)].1)
                .font(.app(16, .semibold)).foregroundStyle(AppColor.textBlack)
            Spacer()
        }
        .background(.white)
        .task { await run() }
    }

    private func run() async {
        for (i, s) in steps.enumerated() {
            stepIdx = i
            withAnimation { percent = s.0 }
            try? await Task.sleep(nanoseconds: 900_000_000)
        }
        onDone()
    }
}

// MARK: - Social proof

private struct SocialProofView: View {
    var onContinue: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image("goFire").resizable().scaledToFit().frame(maxHeight: 200)
            Text("Тебе доверяют тысячи\nбудущих водителей")
                .font(.app(26, .bold)).foregroundStyle(AppColor.textBlack).multilineTextAlignment(.center)
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in Image(systemName: "star.fill").foregroundStyle(AppColor.orange) }
            }
            Text("4.8 · более 10 000 установок").font(.app(15)).foregroundStyle(AppColor.greyText)
            Spacer()
            PrimaryButton(title: "Продолжить", action: onContinue)
                .padding(.horizontal, AppLayout.onboardingMargin).padding(.bottom, 16)
        }
        .background(.white)
    }
}
