//
//  CardModulesView.swift
//  pdd
//
//  Module/task list for a course card, with sequential unlocking.
//

import SwiftUI

struct CardModulesView: View {
    let card: QuizCard
    var onStartTask: (QuizTask) -> Void
    @State private var progress = ProgressStore.shared

    private var flatTasks: [QuizTask] { card.modules.flatMap { $0.tasks } }

    /// A task unlocks when the previous task in the card is completed.
    private func isUnlocked(_ task: QuizTask) -> Bool {
        _ = progress.revision
        guard let idx = flatTasks.firstIndex(of: task) else { return false }
        if idx == 0 { return true }
        return progress.progress(taskId: flatTasks[idx - 1].id).completed
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(card.modules) { module in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Модуль \(module.moduleNo)")
                            .font(.app(18, .bold)).foregroundStyle(AppColor.textBlack)
                        ForEach(module.tasks) { task in
                            taskRow(task)
                        }
                    }
                }
            }
            .padding(.horizontal, AppLayout.homeMargin).padding(.vertical, 16)
        }
        .background(.white)
        .navigationTitle(card.difficulty.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func taskRow(_ task: QuizTask) -> some View {
        let p = progress.progress(taskId: task.id)
        let unlocked = isUnlocked(task)
        return Button { if unlocked { onStartTask(task) } } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(iconBg(done: p.completed, unlocked: unlocked)).frame(width: 46, height: 46)
                    Image(systemName: p.completed ? "checkmark" : unlocked ? (task.isControl ? "flag.checkered" : "play.fill") : "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(unlocked || p.completed ? .white : AppColor.greyText)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.isControl ? "Контрольное задание" : task.title)
                        .font(.app(16, .medium)).foregroundStyle(AppColor.textBlack)
                    Text(p.completed ? "Пройдено · \(p.score)/\(p.total)" : "\(task.difficulty.questionCount) вопросов")
                        .font(.app(13)).foregroundStyle(AppColor.greyText)
                }
                Spacer()
                if unlocked {
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.tabInactive)
                }
            }
            .padding(14)
            .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(unlocked || p.completed ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    private func iconBg(done: Bool, unlocked: Bool) -> Color {
        if done { return AppColor.greenSuccess }
        return unlocked ? AppColor.brandBlue : AppColor.lockGrey
    }
}
