//
//  pddApp.swift
//  pdd
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct pddApp: App {
    init() {
        FirebaseApp.configure()
        // Warm up the question bank off the first view render.
        _ = QuestionBank.shared
        // Bridge progress/streak to the Apple Watch companion app.
        PhoneWatchSync.shared.activate()
        PhoneWatchSync.shared.send(WidgetSnapshot.current())
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(AppColor.brandBlue)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
