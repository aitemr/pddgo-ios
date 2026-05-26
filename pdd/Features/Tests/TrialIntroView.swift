//
//  TrialIntroView.swift
//  pdd
//
//  TestDetailPage — faithful port (flag, title, description, info rows, button).
//

import SwiftUI

struct TestDetailView: View {
    let kind: TrialKind
    var onStart: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var mistakes = MistakesBank.shared

    private var isMistakes: Bool { kind == .individual }
    private var title: String { isMistakes ? L.workOnMistakes : L.testPageTitle }
    private var description: String { isMistakes ? L.testDescriptionIndividual : L.testDescriptionMain }
    private var count: Int { isMistakes ? min(mistakes.count, 40) : 40 }
    private var pass: Int { isMistakes ? count : QuizRules.trialPassThreshold }

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: L.testDetailAppBarTitle) { dismiss() }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Image("flag").resizable().scaledToFill()
                        .frame(width: 80, height: 80).clipShape(Circle())
                        .padding(.top, 30)
                    Text(title)
                        .font(.system(size: 28, weight: .heavy, design: .rounded)).appKerning(28)
                        .foregroundStyle(AppColor.textBlack).lineSpacing(1).padding(.top, 24)
                    Text(description)
                        .font(.system(size: 17, design: .rounded)).appKerning(17)
                        .foregroundStyle(AppColor.textBlack).lineSpacing(5).padding(.top, 16)

                    VStack(spacing: 6) {
                        infoRow(L.questionsCountLabel, "\(count)")
                        infoRow(L.passRequirementLabel, "\(pass)")
                    }
                    .padding(.top, 28)

                    blueButton(L.startTestingBtn, height: 67) {
                        if isMistakes && mistakes.isEmpty { return }
                        onStart(); dismiss()
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 42)
                }
                .padding(.horizontal, 30)
            }
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .rounded)).appKerning(16)
                .foregroundStyle(AppColor.textBlack)
            Spacer()
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded)).appKerning(28)
                .foregroundStyle(AppColor.brandBlue)
        }
        .padding(.horizontal, 22).padding(.vertical, 14)
        .frame(minHeight: 67)
        .background(Color(hex: "#F2F4F7"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Reusable centered top bar with back chevron + bottom divider (Flutter AppBar).
struct AppTopBar: View {
    var title: String
    var trailing: AnyView? = nil
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded)).appKerning(18)
                    .foregroundStyle(AppColor.textBlack)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColor.brandBlue)
                    }.buttonStyle(.plain)
                    Spacer()
                    if let trailing { trailing }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
            Divider().overlay(AppColor.cardBorder)
        }
        .background(.white)
    }
}
