//
//  PddWidgets.swift
//  PddWidgets
//
//  Home-screen + lock-screen widgets for PDD KZ: a study-progress widget and a
//  daily-streak widget, both driven by the shared PddSnapshot.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline

struct PddEntry: TimelineEntry {
    let date: Date
    let snapshot: PddSnapshot
}

struct PddProvider: TimelineProvider {
    func placeholder(in context: Context) -> PddEntry {
        PddEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PddEntry) -> Void) {
        let snap = context.isPreview ? .placeholder : (PddSnapshot.read() ?? .placeholder)
        completion(PddEntry(date: Date(), snapshot: snap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PddEntry>) -> Void) {
        let entry = PddEntry(date: Date(), snapshot: PddSnapshot.read() ?? .placeholder)
        // The app reloads timelines on every quiz finish; this hourly refresh is
        // just a backstop so the streak's "today" state can't go stale.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Progress widget

struct ProgressWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PddProgressWidget", provider: PddProvider()) { entry in
            ProgressWidgetView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ПДД · Прогресс")
        .description("Сколько вопросов из банка вы уже освоили.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

struct ProgressWidgetView: View {
    let snapshot: PddSnapshot
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: snapshot.ratio) {
                Image(systemName: "checkmark.seal.fill")
            } currentValueLabel: {
                Text("\(Int(snapshot.ratio * 100))")
            }
            .gaugeStyle(.accessoryCircular)
        case .systemMedium:
            HStack(spacing: 16) {
                ring
                VStack(alignment: .leading, spacing: 6) {
                    Text("Прогресс ПДД").font(.headline)
                    Text("\(snapshot.correctTotal) из \(snapshot.questionBankTotal) вопросов")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Label("\(snapshot.currentStreak) дн. подряд", systemImage: "flame.fill")
                        .font(.caption).foregroundStyle(.orange)
                }
                Spacer(minLength: 0)
            }
        default:
            VStack(spacing: 8) {
                ring
                Text("\(snapshot.correctTotal)/\(snapshot.questionBankTotal)")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.pddBlue.opacity(0.15), lineWidth: 9)
            Circle().trim(from: 0, to: snapshot.ratio)
                .stroke(Color.pddBlue, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(snapshot.ratio * 100))%").font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .frame(width: 64, height: 64)
        .accessibilityLabel("Прогресс \(Int(snapshot.ratio * 100)) процентов")
    }
}

// MARK: - Streak widget

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PddStreakWidget", provider: PddProvider()) { entry in
            StreakWidgetView(snapshot: entry.snapshot)
                .containerBackground(streakBackground, for: .widget)
        }
        .configurationDisplayName("ПДД · Серия")
        .description("Ваша ежедневная серия подготовки к экзамену.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline])
    }

    private var streakBackground: LinearGradient {
        LinearGradient(colors: [Color.pddOrange, Color(red: 1, green: 0x8A / 255, blue: 0)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct StreakWidgetView: View {
    let snapshot: PddSnapshot
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Label("\(snapshot.currentStreak) дн. серия", systemImage: "flame.fill")
        case .accessoryCircular:
            Gauge(value: Double(min(snapshot.currentStreak, 30)), in: 0...30) {
                Image(systemName: "flame.fill")
            } currentValueLabel: {
                Text("\(snapshot.currentStreak)")
            }
            .gaugeStyle(.accessoryCircular)
        case .systemMedium:
            VStack(alignment: .leading, spacing: 10) {
                header
                Text(snapshot.isActiveToday ? "Сегодня отмечено — так держать!" : "Пройдите тест, чтобы продлить серию")
                    .font(.caption).foregroundStyle(.white.opacity(0.9))
            }
            .foregroundStyle(.white)
        default:
            VStack(spacing: 6) {
                Image(systemName: "flame.fill").font(.system(size: 34)).foregroundStyle(.white)
                Text("\(snapshot.currentStreak)").font(.system(size: 30, weight: .heavy, design: .rounded))
                Text("дней подряд").font(.caption2)
            }
            .foregroundStyle(.white)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Серия \(snapshot.currentStreak) дней подряд")
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "flame.fill").font(.title2)
            VStack(alignment: .leading, spacing: 0) {
                Text("\(snapshot.currentStreak)").font(.system(size: 32, weight: .heavy, design: .rounded))
                Text("дней подряд").font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("Рекорд").font(.caption2).opacity(0.9)
                Text("\(snapshot.longestStreak)").font(.headline)
            }
        }
    }
}

// MARK: - Bundle

@main
struct PddWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        ProgressWidget()
    }
}
