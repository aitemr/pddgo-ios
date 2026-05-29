//
//  HomeRootView.swift
//  pdd
//
//  Home tab (spec §9): welcome header, level carousels, useful materials, progress.
//

import SwiftUI

struct UsefulMaterial: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
    let prompt: String
}

enum HomeRoute: Hashable { case card(String), material(UsefulMaterial), videoLessons }

struct HomeRootView: View {
    @State private var path = NavigationPath()
    @State private var launch: QuizConfig?
    @State private var progress = ProgressStore.shared

    private let materials: [UsefulMaterial] = [
        .init(title: "Дорожные знаки", image: "materialsSigns", prompt: "Кратко опиши основные группы дорожных знаков Казахстана с примерами."),
        .init(title: "Первая помощь", image: "TrafficLights", prompt: "Расскажи об оказании первой помощи при ДТП по правилам РК."),
        .init(title: "Основы первой помощи", image: "materialsRoad", prompt: "Опиши базовые приёмы первой помощи, которые должен знать водитель."),
        .init(title: "Штрафы", image: "useful_materials_go", prompt: "Перечисли распространённые штрафы за нарушение ПДД в Казахстане."),
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    videoBanner
                    sectionTitle("Практический курс", subtitle: "Проходи уровни от простого к сложному")
                    ForEach(Difficulty.allCases, id: \.self) { level in
                        levelCarousel(level)
                    }
                    sectionTitle("Полезные материалы", subtitle: nil).padding(.top, 8)
                    materialsGrid
                }
                .padding(.bottom, 24)
            }
            .background(.white)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .card(let id):
                    if let card = QuizCatalog.card(id: id) {
                        CardModulesView(card: card) { launch = .catalogTask($0) }
                    }
                case .material(let m):
                    UsefulMaterialDetailView(material: m)
                case .videoLessons:
                    VideoLessonsPage()
                }
            }
            .quizFlow(item: $launch)
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            AppColor.brandBlue
            Image("driving_student").resizable().scaledToFit()
                .frame(height: 180).frame(maxWidth: .infinity, alignment: .trailing).opacity(0.95)
            VStack(alignment: .leading, spacing: 8) {
                Text("Добро пожаловать!").font(.app(28, .bold)).foregroundStyle(.white)
                Text("Готовься к экзамену по ПДД РК").font(.app(16)).foregroundStyle(.white.opacity(0.9))
                HStack(spacing: 10) {
                    progressBadge
                    StreakBadge()
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, AppLayout.homeMargin)
            .padding(.bottom, 24)
        }
        .frame(height: 320)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30))
    }

    private var progressBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill").foregroundStyle(.white)
            Text("\(progress.correctTotal) правильных ответов")
                .font(.app(14, .semibold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(.white.opacity(0.18), in: Capsule())
    }

    private var videoBanner: some View {
        Button { path.append(HomeRoute.videoLessons) } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.rectangle.fill").font(.system(size: 26)).foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Видеоуроки").font(.app(17, .semibold)).foregroundStyle(.white)
                    Text("Смотри и учись на примерах").font(.app(13)).foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.9))
            }
            .padding(18)
            .background(LinearGradient(colors: [AppColor.purpleAccent, AppColor.purpleDark],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppLayout.homeMargin).padding(.top, 16)
    }

    private func sectionTitle(_ title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.app(22, .bold)).foregroundStyle(AppColor.textBlack)
            if let subtitle { Text(subtitle).font(.app(14)).foregroundStyle(AppColor.greyText) }
        }
        .padding(.horizontal, AppLayout.homeMargin).padding(.top, 24)
    }

    // MARK: Level carousel

    private func levelCarousel(_ level: Difficulty) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(level.title).font(.app(16, .semibold)).foregroundStyle(AppColor.greyText)
                .padding(.horizontal, AppLayout.homeMargin).padding(.top, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(QuizCatalog.cards(for: level)) { card in
                        CourseCard(card: card) { path.append(HomeRoute.card(card.id)) }
                    }
                }
                .padding(.horizontal, AppLayout.homeMargin)
            }
        }
    }

    // MARK: Materials

    private var materialsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            ForEach(materials) { m in
                Button { path.append(HomeRoute.material(m)) } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(m.image).resizable().scaledToFill()
                            .frame(height: 90).frame(maxWidth: .infinity).clipped()
                        Text(m.title).font(.app(15, .semibold)).foregroundStyle(AppColor.textBlack)
                            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppLayout.homeMargin).padding(.top, 12)
    }
}

struct CourseCard: View {
    let card: QuizCard
    var onTap: () -> Void
    @State private var progress = ProgressStore.shared

    private var completed: Int {
        _ = progress.revision
        return card.modules.flatMap { $0.tasks }.filter { progress.progress(taskId: $0.id).completed }.count
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    LinearGradient(colors: [AppColor.brandBlue, AppColor.brandBlue2],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image("pdd_go_card").resizable().scaledToFit().padding(24)
                }
                .frame(height: 150)
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.difficulty.title).font(.app(16, .semibold)).foregroundStyle(AppColor.textBlack)
                    Text("\(completed) / \(card.totalTasks) заданий")
                        .font(.app(13)).foregroundStyle(AppColor.greyText)
                    ProgressView(value: Double(completed), total: Double(card.totalTasks))
                        .tint(AppColor.brandBlue)
                }
                .padding(14)
            }
            .frame(width: 260)
            .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
