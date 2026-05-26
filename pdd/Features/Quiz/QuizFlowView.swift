//
//  QuizFlowView.swift
//  pdd
//
//  Full-screen quiz → results → (streak) container.
//

import SwiftUI

struct QuizFlowView: View {
    let config: QuizConfig
    @Environment(\.dismiss) private var dismiss

    @State private var vm: QuizViewModel
    @State private var result: QuizResult?
    @State private var showStreak = false

    init(config: QuizConfig) {
        self.config = config
        _vm = State(initialValue: QuizViewModel(config: config))
    }

    var body: some View {
        Group {
            if showStreak {
                StreakView { dismiss() }
            } else if let result {
                ResultsView(result: result,
                            onPrimary: { handlePrimary(result) },
                            onClose: { dismiss() })
            } else {
                QuizPage(vm: vm, onClose: { dismiss() })
            }
        }
        .onAppear { vm.onFinish = { result = $0 } }
    }

    private func handlePrimary(_ r: QuizResult) {
        switch r.type {
        case .success:
            if r.isTrialExam { showStreak = true } else { dismiss() }
        case .failure:
            restart()
        case .completion:
            dismiss()
        }
    }

    private func restart() {
        let fresh = QuizViewModel(config: config)
        fresh.onFinish = { result = $0 }
        vm = fresh
        result = nil
        showStreak = false
    }
}

extension View {
    /// Presents a quiz flow full-screen for a non-nil config.
    func quizFlow(item: Binding<QuizConfig?>) -> some View {
        fullScreenCover(item: item) { config in
            QuizFlowView(config: config)
        }
    }
}
