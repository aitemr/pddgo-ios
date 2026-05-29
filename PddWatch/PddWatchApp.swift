//
//  PddWatchApp.swift
//  PddWatch
//
//  watchOS companion app: shows the user's PDD study streak and progress,
//  synced from the iPhone app over WatchConnectivity.
//

import SwiftUI

@main
struct PddWatchApp: App {
    @State private var session = WatchSession.shared

    init() {
        WatchSession.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchStreakView(snapshot: session.snapshot)
        }
    }
}

struct WatchStreakView: View {
    let snapshot: WatchSnapshot

    private var progress: Double {
        guard snapshot.questionBankTotal > 0 else { return 0 }
        return min(1, Double(snapshot.correctTotal) / Double(snapshot.questionBankTotal))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(snapshot.currentStreak > 0 ? .orange : .gray)
                Text("\(snapshot.currentStreak)")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                Text("дней подряд")
                    .font(.footnote).foregroundStyle(.secondary)

                Gauge(value: progress) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(progress * 100))%")
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.blue)
                .padding(.top, 4)

                HStack(spacing: 12) {
                    stat(title: "Рекорд", value: "\(snapshot.longestStreak)")
                    stat(title: "Верно", value: "\(snapshot.correctTotal)")
                }
                .padding(.top, 4)

                if !snapshot.isActiveToday {
                    Text("Пройди тест сегодня")
                        .font(.caption2).foregroundStyle(.orange).padding(.top, 2)
                }
            }
            .padding(.horizontal, 6)
        }
        .containerBackground(.orange.gradient, for: .navigation)
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
