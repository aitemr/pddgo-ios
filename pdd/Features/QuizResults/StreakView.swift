//
//  StreakView.swift
//  pdd
//
//  Completion screen (results_screen.dart _buildCompletion) — goFire + streak.
//

import SwiftUI

struct CompletionView: View {
    var onContinue: () -> Void

    private let days = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВСК"]
    private let fireOn = [false, false, true, true, false, false, false]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            Image("goFire").resizable().scaledToFit().frame(height: 240)
            Text(L.completionTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center).foregroundStyle(AppColor.textBlack).padding(.top, 40)
            Text(L.completionSubtitle)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.black.opacity(0.54)).multilineTextAlignment(.center).padding(.top, 12)
            streakRow.padding(.horizontal, 16).padding(.top, 48)
            Spacer()
            blueButton(L.continueBtn, height: 72, action: onContinue)
                .padding(20)
        }
        .background(.white)
    }

    private var streakRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                VStack(spacing: 8) {
                    Text(day).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(.black.opacity(0.87))
                    if fireOn[i] {
                        Image("iconFire").renderingMode(.template).resizable().scaledToFit()
                            .frame(width: 24, height: 24).foregroundStyle(.orange)
                    } else {
                        Color.clear.frame(height: 24)
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .overlay(alignment: .trailing) {
                    if i < days.count - 1 { Rectangle().fill(.black.opacity(0.12)).frame(width: 0.5) }
                }
            }
        }
        .background(Color(hex: "#F2F4F7"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
