//
//  SplashView.swift
//  pdd
//

import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#31A1FD").ignoresSafeArea()
            Image("splash_screen_background")
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            Image("Group 22")
                .resizable().scaledToFit().frame(height: 250)
                .frame(maxHeight: .infinity)
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            app.resolveAfterSplash()
        }
    }
}
