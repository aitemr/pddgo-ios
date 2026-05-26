//
//  TrialIntroView.swift
//  pdd
//
//  Trial-exam intro (Figma "Индивидуальное тестирование").
//

import SwiftUI

struct TrialIntroView: View {
    let kind: TrialKind
    var onStart: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var isIndividual: Bool { kind == .individual }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Text(isIndividual ? "Индивидуальное" : "Пробное тестирование")
                    .font(.app(18, .medium)).foregroundStyle(AppColor.textBlack)
                HStack { BackButton { dismiss() }; Spacer() }
            }
            .padding(.horizontal, AppLayout.homeMargin).padding(.top, 8).padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack {
                        Circle().fill(AppColor.brandBlue2).frame(width: 56, height: 56)
                        Image("KZ").resizable().scaledToFit().frame(width: 56, height: 56).padding(12)
                    }

                    Text(isIndividual ? "Индивидуальное\nтестирование" : "Пробное\nтестирование")
                        .font(.app(28, .bold)).foregroundStyle(AppColor.textBlack)

                    Text(isIndividual
                         ? "Хочешь сдать ПДД без второго шанса?\nНачни с умной подготовки. Этот тест адаптирован под тебя: он не тратит время на то, что ты уже знаешь, и бьёт точно по ошибкам."
                         : "Проверь свою готовность к экзамену. 40 вопросов как на реальной сдаче — с таймером и проходным баллом.")
                        .font(.app(16)).foregroundStyle(AppColor.greyText).lineSpacing(3)

                    VStack(spacing: 12) {
                        infoRow("Количество вопросов:", "\(QuizRules.trialQuestionCount)")
                        infoRow("Для успешной сдачи необходимо:", "\(QuizRules.trialPassThreshold)")
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, AppLayout.homeMargin)
                .padding(.bottom, 24)
            }

            PrimaryButton(title: "Начать тестирование") { onStart() }
                .padding(.horizontal, AppLayout.homeMargin)
                .padding(.bottom, 12)
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.app(16)).foregroundStyle(AppColor.textBlack)
            Spacer()
            Text(value).font(.app(18, .bold)).foregroundStyle(AppColor.brandBlue)
        }
        .padding(.horizontal, 20).frame(height: 64)
        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
