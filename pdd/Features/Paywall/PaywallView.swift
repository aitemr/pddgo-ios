//
//  PaywallView.swift
//  pdd
//
//  Faithful port of paywall_page.dart.
//

import SwiftUI

private struct Plan: Identifiable {
    let id: String
    let title: String
    let price: String
    let period: String
    let pricePerDay: String
    let badge: String?
}

struct PaywallView: View {
    var canDismiss: Bool
    var subscriptionRequired: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app

    @State private var selectedId = "monthly"
    @State private var closeVisible = false
    @State private var purchasing = false

    private let plans: [Plan] = [
        Plan(id: "weekly", title: L.paywallPlanWeekly, price: L.paywallPriceWeekly,
             period: L.paywallPeriodWeekly, pricePerDay: L.paywallPerDayWeekly, badge: nil),
        Plan(id: "monthly", title: L.paywallPlanMonthly, price: L.paywallPriceMonthly,
             period: L.paywallPeriodMonthly, pricePerDay: L.paywallPerDayMonthly, badge: L.paywallBadgeBestDeal),
    ]
    private var selectedPlan: Plan { plans.first { $0.id == selectedId } ?? plans[1] }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Image("Akzhol").resizable().scaledToFit().frame(height: 160).padding(.top, 8)
                    hero.padding(.top, 16)
                    Text(L.paywallSubtitle)
                        .font(.system(size: 16, design: .rounded)).appKerning(16)
                        .foregroundStyle(Color(hex: "#B6B6B6"))
                        .multilineTextAlignment(.center).lineSpacing(4).padding(.top, 8)
                    features.padding(.top, 18)
                    VStack(spacing: 12) {
                        ForEach(plans) { planCard($0) }
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 24)
            }
            cta
        }
        .background(.white)
        .task {
            if canDismiss { closeVisible = true }
            else {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                withAnimation { closeVisible = true }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Color.clear.frame(width: 36, height: 36)
            Spacer()
            Image("GoB").resizable().scaledToFit().frame(height: 36)
            Spacer()
            Group {
                if closeVisible {
                    Button(action: close) {
                        Image(systemName: "xmark").font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color(hex: "#B6B6B6"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "#F5F5F5"), in: Circle())
                    }.buttonStyle(.plain).transition(.opacity)
                } else { Color.clear }
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
    }

    private var hero: some View {
        (Text(L.paywallHeroPrefix).foregroundColor(AppColor.textBlack)
         + Text(L.paywallHeroHighlight).foregroundColor(AppColor.brandBlue))
            .font(.system(size: 26, weight: .heavy, design: .rounded))
            .multilineTextAlignment(.center).lineSpacing(4)
    }

    private var features: some View {
        VStack(spacing: 6) {
            ForEach([L.paywallFeatureVideos, L.paywallFeatureTests, L.paywallFeatureAkzhol, L.paywallFeatureMistakes], id: \.self) { f in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundStyle(AppColor.brandBlue)
                        .frame(width: 22)
                    Text(f).font(.system(size: 14, weight: .semibold, design: .rounded)).appKerning(14)
                        .foregroundStyle(AppColor.textBlack)
                    Spacer()
                }
            }
        }
    }

    private func planCard(_ plan: Plan) -> some View {
        let selected = plan.id == selectedId
        return Button { selectedId = plan.id } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(AppColor.textBlack)
                    Text(plan.pricePerDay).font(.system(size: 12, design: .rounded)).foregroundStyle(Color(hex: "#B6B6B6"))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price).font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(selected ? AppColor.brandBlue : AppColor.textBlack)
                    Text(plan.period).font(.system(size: 12, design: .rounded)).foregroundStyle(Color(hex: "#B6B6B6"))
                }
                .padding(.trailing, 14)
                ZStack {
                    Circle().fill(selected ? AppColor.brandBlue : .white).frame(width: 26, height: 26)
                        .overlay(Circle().stroke(selected ? AppColor.brandBlue : Color(hex: "#DDDDDD"), lineWidth: 2))
                    if selected { Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(.white) }
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(selected ? AppColor.brandBlue.opacity(0.07) : Color(hex: "#F5F5F5"),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? AppColor.brandBlue : Color(hex: "#F5F5F5"), lineWidth: 1.8))
            .overlay(alignment: .topTrailing) {
                if let badge = plan.badge {
                    Text(badge.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded)).tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 4)
                        .background(.black.opacity(0.87), in: Capsule())
                        .padding(.trailing, 20).offset(y: -13)
                }
            }
            .padding(.top, plan.badge != nil ? 14 : 0)
        }
        .buttonStyle(.plain)
    }

    private var cta: some View {
        VStack(spacing: 0) {
            Button(action: subscribe) {
                Group {
                    if purchasing { ProgressView().tint(.white) }
                    else {
                        Text(L.paywallCtaWithPrice(selectedPlan.price))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 58)
                .background(AppColor.brandBlue.opacity(purchasing ? 0.6 : 1), in: RoundedRectangle(cornerRadius: 35, style: .continuous))
            }.buttonStyle(.plain).disabled(purchasing)

            Text(L.paywallCancelAnytime).font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#B6B6B6")).padding(.top, 8)
            Text(L.paywallDisclaimerAfterTrial).font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color(hex: "#B6B6B6")).multilineTextAlignment(.center).lineSpacing(3).padding(.top, 2)

            HStack(spacing: 6) {
                footerLink(L.privacyPolicy) {}
                Text("·").foregroundStyle(Color(hex: "#B6B6B6"))
                footerLink(L.termsOfUse) {}
                Text("·").foregroundStyle(Color(hex: "#B6B6B6"))
                footerLink(L.paywallRestorePurchases) { restore() }
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 24).padding(.vertical, 20)
    }

    private func footerLink(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 12, design: .rounded)).underline()
                .foregroundStyle(AppColor.brandBlue)
        }.buttonStyle(.plain)
    }

    private func close() {
        Haptics.impact()
        if app.route == .paywall { app.enterMain() } else { dismiss() }
    }
    private func subscribe() {
        purchasing = true
        Task { @MainActor in
            do { try await SubscriptionGate.shared.purchase(productId: selectedId) } catch {}
            #if DEBUG
            SubscriptionGate.shared.debugSetPremium(true)
            #endif
            await SubscriptionGate.shared.refresh()
            purchasing = false
            if app.route == .paywall { app.enterMain() } else { dismiss() }
        }
    }
    private func restore() {
        Task { @MainActor in
            try? await SubscriptionGate.shared.restore()
            await SubscriptionGate.shared.refresh()
            if app.route == .paywall { app.enterMain() } else { dismiss() }
        }
    }
}
