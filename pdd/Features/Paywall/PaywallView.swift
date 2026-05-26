//
//  PaywallView.swift
//  pdd
//
//  RevenueCat-backed paywall (spec §12). The default build simulates purchase
//  so the funnel completes; wire SubscriptionGate.purchase/restore to go live.
//

import SwiftUI

struct PaywallView: View {
    var canDismiss: Bool
    var subscriptionRequired: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app
    @State private var selected: SubscriptionProduct = .monthly
    @State private var showClose = false
    @State private var busy = false

    private let benefits = [
        "Безлимитные видеоуроки",
        "Безлимитная практика ПДД",
        "Акжол без ограничений",
        "Аналитика твоих ошибок",
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColor.appBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("GO").font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColor.brandBlue).padding(.top, 40)
                    Text("PDD Premium").font(.app(28, .bold)).foregroundStyle(AppColor.textBlack)
                    Text("Открой все возможности приложения")
                        .font(.app(16)).foregroundStyle(AppColor.greyText).padding(.top, 4)

                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(benefits, id: \.self) { b in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColor.greenSuccess).font(.system(size: 22))
                                Text(b).font(.app(16, .medium)).foregroundStyle(AppColor.textBlack)
                            }
                        }
                    }
                    .padding(.horizontal, 6).padding(.top, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 12) {
                        ForEach(SubscriptionProduct.allCases, id: \.self) { product in
                            productCard(product)
                        }
                    }
                    .padding(.top, 28)

                    PrimaryButton(title: busy ? "Оформляем…" : "Оформить подписку", showsChevron: false, enabled: !busy) {
                        subscribe()
                    }
                    .padding(.top, 20)

                    Button("Восстановить покупки") { restore() }
                        .font(.app(14, .medium)).foregroundStyle(AppColor.greyText).padding(.top, 14)
                }
                .padding(.horizontal, AppLayout.profileMargin)
                .padding(.bottom, 30)
            }

            if canDismiss && showClose {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28)).foregroundStyle(AppColor.greyText.opacity(0.6))
                }
                .padding(20)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            showClose = true
        }
    }

    private func productCard(_ product: SubscriptionProduct) -> some View {
        let isSelected = product == selected
        return Button { selected = product } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.period.capitalized).font(.app(17, .semibold)).foregroundStyle(AppColor.textBlack)
                    if product.isBestValue {
                        Text("Выгодно").font(.app(12, .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(AppColor.orange, in: Capsule())
                    }
                }
                Spacer()
                Text(product.price).font(.app(20, .bold)).foregroundStyle(AppColor.brandBlue)
            }
            .padding(18)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? AppColor.brandBlue : AppColor.cardBorder, lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    private func subscribe() {
        busy = true
        Task { @MainActor in
            do { try await SubscriptionGate.shared.purchase(productId: selected.rawValue) }
            catch {}
            #if DEBUG
            SubscriptionGate.shared.debugSetPremium(true)   // simulate success in dev builds
            #endif
            await SubscriptionGate.shared.refresh()
            busy = false
            finish()
        }
    }

    private func restore() {
        Task { @MainActor in
            try? await SubscriptionGate.shared.restore()
            await SubscriptionGate.shared.refresh()
            finish()
        }
    }

    private func finish() {
        if app.route == .paywall { app.enterMain() } else { dismiss() }
    }
}
