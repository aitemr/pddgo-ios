//
//  VideoLessonsPage.swift
//  pdd
//
//  Video lessons + lesson practice (spec §15), reusing the quiz engine.
//

import SwiftUI
import AVKit

struct VideoLesson: Identifiable, Hashable {
    let id: String
    let title: String
    let duration: String
    let description: String
    let preview: String
    let videoURL: URL?
    let moduleNo: Int
}

enum VideoLessonsData {
    private static let sampleVideo = QuestionBank.shared.all.first(where: { $0.videoURL != nil })?.videoURL

    static let lessons: [VideoLesson] = [
        .init(id: "l1", title: "Дорожные знаки: основы", duration: "6:20",
              description: "Группы знаков, приоритет и как их быстро запоминать.", preview: "exampleVideo", videoURL: sampleVideo, moduleNo: 1),
        .init(id: "l2", title: "Проезд перекрёстков", duration: "8:05",
              description: "Регулируемые и нерегулируемые перекрёстки на примерах.", preview: "tigervideo", videoURL: sampleVideo, moduleNo: 1),
        .init(id: "l3", title: "Обгон и манёвры", duration: "5:40",
              description: "Когда обгон запрещён и как действовать безопасно.", preview: "videobanner", videoURL: sampleVideo, moduleNo: 2),
        .init(id: "l4", title: "Парковка и остановка", duration: "4:55",
              description: "Правила остановки, стоянки и частые ошибки.", preview: "materialsRoad", videoURL: sampleVideo, moduleNo: 2),
    ]
}

struct VideoLessonsPage: View {
    @State private var launch: QuizConfig?
    @State private var path = NavigationPath()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Image("videobanner").resizable().scaledToFill()
                    .frame(height: 180).frame(maxWidth: .infinity).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text("Видеоуроки").font(.app(24, .bold)).foregroundStyle(AppColor.textBlack)
                Text("Понятные объяснения с наглядными примерами")
                    .font(.app(14)).foregroundStyle(AppColor.greyText)

                ForEach([1, 2], id: \.self) { module in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Модуль \(module)").font(.app(18, .bold)).foregroundStyle(AppColor.textBlack)
                        ForEach(VideoLessonsData.lessons.filter { $0.moduleNo == module }) { lesson in
                            NavigationLink(value: lesson) { LessonRow(lesson: lesson) }
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, AppLayout.homeMargin).padding(.vertical, 12)
        }
        .background(.white)
        .navigationTitle("Видеоуроки").navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: VideoLesson.self) { lesson in
            VideoLessonDetailView(lesson: lesson) {
                launch = .lessonPractice(id: lesson.id, title: lesson.title)
            }
        }
        .quizFlow(item: $launch)
    }
}

private struct LessonRow: View {
    let lesson: VideoLesson
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Image(lesson.preview).resizable().scaledToFill()
                    .frame(width: 90, height: 64).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title).font(.app(15, .semibold)).foregroundStyle(AppColor.textBlack)
                Text(lesson.duration).font(.app(12)).foregroundStyle(AppColor.greyText)
            }
            Spacer()
        }
        .padding(10)
        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct VideoLessonDetailView: View {
    let lesson: VideoLesson
    var onPractice: () -> Void
    @State private var rating = 0   // -1 down, 1 up

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if let url = lesson.videoURL {
                        VideoPlayer(player: AVPlayer(url: url)).frame(height: 220)
                    } else {
                        Image(lesson.preview).resizable().scaledToFill().frame(height: 220).clipped()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                HStack {
                    Text(lesson.title).font(.app(22, .bold)).foregroundStyle(AppColor.textBlack)
                    Spacer()
                    Text(lesson.duration).font(.app(13, .medium)).foregroundStyle(AppColor.greyText)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(AppColor.lightBg, in: Capsule())
                }
                Text(lesson.description).font(.app(16)).foregroundStyle(AppColor.textBlack).lineSpacing(4)

                HStack(spacing: 16) {
                    rateButton(.init(systemName: "hand.thumbsup"), value: 1)
                    rateButton(.init(systemName: "hand.thumbsdown"), value: -1)
                    Spacer()
                }

                PrimaryButton(title: "Практика", showsChevron: false) {
                    if UsageLimits.shared.canStartLessonPractice(hash: lesson.id) { onPractice() }
                    else { onPractice() }   // gate hint; practice still openable in dev
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, AppLayout.homeMargin).padding(.vertical, 12)
        }
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rateButton(_ image: Image, value: Int) -> some View {
        Button { rating = value } label: {
            image.font(.system(size: 20, weight: .semibold))
                .foregroundStyle(rating == value ? .white : AppColor.brandBlue)
                .frame(width: 48, height: 48)
                .background(rating == value ? AppColor.brandBlue : AppColor.lightBg, in: Circle())
        }.buttonStyle(.plain)
    }
}
