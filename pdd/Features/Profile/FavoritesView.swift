//
//  FavoritesView.swift
//  pdd
//

import SwiftUI

struct FavoritesView: View {
    @State private var favorites = Favorites.shared
    private var session = Session.shared

    var body: some View {
        Group {
            if favorites.questions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star").font(.system(size: 48)).foregroundStyle(AppColor.tabInactive)
                    Text("Нет избранных вопросов").font(.app(16)).foregroundStyle(AppColor.greyText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(favorites.questions) { q in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(q.localizedQuestion(session.language))
                                    .font(.app(15, .medium)).foregroundStyle(AppColor.textBlack)
                                if q.correctIndex >= 0 {
                                    Text("Ответ: " + q.answers[q.correctIndex].localized(session.language))
                                        .font(.app(13)).foregroundStyle(AppColor.greenCorrect)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(alignment: .topTrailing) {
                                Button { favorites.toggle(id: q.id) } label: {
                                    Image(systemName: "star.fill").foregroundStyle(AppColor.orange)
                                }.padding(12)
                            }
                        }
                    }
                    .padding(AppLayout.profileMargin)
                }
            }
        }
        .background(.white)
        .navigationTitle("Избранное").navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session = Session.shared

    var body: some View {
        VStack(spacing: 0) {
            Text("Выберите язык").font(.app(18, .semibold)).foregroundStyle(AppColor.textBlack).padding(.vertical, 18)
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                Button {
                    session.language = lang
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Text(lang.flag).font(.system(size: 26))
                        Text(lang.displayName).font(.app(16, .medium)).foregroundStyle(AppColor.textBlack)
                        Spacer()
                        if session.language == lang {
                            Image(systemName: "checkmark").foregroundStyle(AppColor.brandBlue)
                        }
                    }
                    .padding(.horizontal, 20).frame(height: 56).contentShape(Rectangle())
                }.buttonStyle(.plain)
                if lang != AppLanguage.allCases.last {
                    Rectangle().fill(AppColor.divider).frame(height: 1).padding(.leading, 60)
                }
            }
            Spacer()
        }
        .presentationDetents([.height(280)])
    }
}
