//
//  pddApp.swift
//  pdd
//

import SwiftUI

@main
struct pddApp: App {
    init() {
        // Warm up the question bank off the first view render.
        _ = QuestionBank.shared
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(AppColor.brandBlue)
        }
    }
}
