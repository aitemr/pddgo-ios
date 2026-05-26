//
//  StreakView.swift
//  pdd
//
//  Post-success streak screen (Figma).
//

import SwiftUI

struct StreakView: View {
    var onContinue: () -> Void

    private let days = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВСК"]
    private let fireDays: Set<Int> = [2, 3]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Text("GO")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColor.brandBlue)
                Text("🔥").font(.system(size: 86)).offset(y: 6)
            }
            Text("Вы уже на шаг ближе\nк своим правам!")
                .font(.app(24, .bold))
                .foregroundStyle(AppColor.textBlack)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
            Text("Продолжайте обучение и будьте готовы\nк успешной сдаче экзамена")
                .font(.app(16))
                .foregroundStyle(AppColor.greyText)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            weekRow.padding(.top, 28).padding(.horizontal, AppLayout.homeMargin)

            Spacer()
            PrimaryButton(title: "Продолжить", action: onContinue)
                .padding(.horizontal, AppLayout.homeMargin)
                .padding(.bottom, 12)
        }
        .background(.white)
    }

    private var weekRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                Text(fireDays.contains(i) ? "🔥" : day)
                    .font(.app(14, .medium))
                    .foregroundStyle(AppColor.textBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                if i < days.count - 1 {
                    Rectangle().fill(AppColor.divider).frame(width: 1, height: 30)
                }
            }
        }
        .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
