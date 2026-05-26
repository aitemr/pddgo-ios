//
//  SplashView.swift
//  pdd
//

import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ZStack {
            AppColor.brandBlue.ignoresSafeArea()
            Image("splash_screen_background")
                .resizable().scaledToFill()
                .ignoresSafeArea()
                .opacity(0.5)
            VStack(spacing: 10) {
                Text("GO")
                    .font(.system(size: 120, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFE000"))
                Text("ПДД")
                    .font(.app(20, .bold))
                    .foregroundStyle(AppColor.brandBlue)
                    .padding(.horizontal, 18).padding(.vertical, 6)
                    .background(.white, in: Capsule())
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            app.resolveAfterSplash()
        }
    }
}
