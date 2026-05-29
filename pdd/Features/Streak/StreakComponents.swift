//
//  StreakComponents.swift
//  pdd
//
//  Reusable streak UI backed by StreakStore: a compact badge for the Home
//  header and a full card (current + best + week fires) for Profile.
//

import SwiftUI

/// Compact flame pill, e.g. on the Home header next to the progress badge.
struct StreakBadge: View {
    @State private var streak = StreakStore.shared

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(streak.current > 0 ? AppColor.orange : .white.opacity(0.5))
            Text("\(streak.current)")
                .font(.app(14, .semibold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(.white.opacity(0.18), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L.streakTitle)
        .accessibilityValue(L.streakDays(streak.current))
    }
}

/// Full streak card for Profile: current streak, best, and the week fire row.
struct StreakCard: View {
    @State private var streak = StreakStore.shared

    private var fireOn: [Bool] { streak.weekFires() }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(streak.current > 0 ? .orange : .white.opacity(0.6))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L.streakTitle)
                        .font(.system(size: 16, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                    Text(L.streakDays(streak.current))
                        .font(.system(size: 24, weight: .bold, design: .rounded)).appKerning(24)
                        .foregroundStyle(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(L.streakBest)
                        .font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                    Text("\(streak.longest)")
                        .font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
                }
            }
            weekRow.padding(.top, 18)
            Text(streak.current > 0 ? L.streakKeepGoing : L.streakEmptyHint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85)).padding(.top, 12)
        }
        .padding(22)
        .background(
            LinearGradient(colors: [AppColor.orange, Color(hex: "#FF8A00")],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(L.streakTitle): \(L.streakDays(streak.current)). \(L.streakBest): \(streak.longest)")
    }

    private var weekRow: some View {
        let days = L.streakWeekDays
        return HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                VStack(spacing: 8) {
                    Text(day)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                    Image(systemName: "flame.fill")
                        .resizable().scaledToFit().frame(width: 18, height: 18)
                        .foregroundStyle(i < fireOn.count && fireOn[i] ? .white : .white.opacity(0.25))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }
}
