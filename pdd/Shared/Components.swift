//
//  Components.swift
//  pdd
//
//  Reusable controls shared across features (Figma redesign styling).
//

import SwiftUI
internal import Combine

/// Full-width filled blue action button.
struct PrimaryButton: View {
    let title: String
    var showsChevron: Bool = true
    var enabled: Bool = true
    var background: Color = AppColor.brandBlue
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            HStack(spacing: 8) {
                Text(title).font(.app(18, .semibold))
                if showsChevron {
                    Image(systemName: "chevron.right").font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(background.opacity(enabled ? 1 : 0.4), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// White outlined secondary button, optionally with a leading avatar.
struct SecondaryButton: View {
    let title: String
    var showsAvatar: Bool = false
    var tint: Color = AppColor.brandBlue
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            HStack(spacing: 8) {
                if showsAvatar {
                    Image("AkzholAvatar").resizable().scaledToFill()
                        .frame(width: 26, height: 26).clipShape(Circle())
                }
                Text(title).font(.app(16, .medium))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.white, in: Capsule())
            .overlay(Capsule().stroke(tint, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

/// Circular icon button (send / next arrow).
struct CircleIconButton: View {
    var systemName: String
    var size: CGFloat = 42
    var background: Color = AppColor.brandBlue
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(background.opacity(enabled ? 1 : 0.35), in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Animated three-dot typing indicator.
struct TypingDots: View {
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var color: Color = AppColor.brandBlue

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i <= phase ? color : color.opacity(0.35))
                    .frame(width: 8, height: 8)
            }
        }
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}

/// Speech bubble with three sound bars — the Акжол tab glyph.
struct VoiceChatGlyph: View {
    var body: some View {
        BubbleShape()
            .overlay(
                HStack(spacing: 3) {
                    bar(0.45); bar(0.85); bar(0.6)
                }
                .padding(.bottom, 4)
                .blendMode(.destinationOut)
            )
            .compositingGroup()
    }
    private func bar(_ h: CGFloat) -> some View {
        Capsule().frame(width: 3, height: 15 * h)
    }
}

private struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let bubble = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - 4)
        p.addRoundedRect(in: bubble, cornerSize: CGSize(width: 7, height: 7))
        p.move(to: CGPoint(x: bubble.minX + 5, y: bubble.maxY - 2))
        p.addLine(to: CGPoint(x: bubble.minX + 2, y: rect.maxY))
        p.addLine(to: CGPoint(x: bubble.minX + 11, y: bubble.maxY - 2))
        p.closeSubpath()
        return p
    }
}

/// Standard back chevron used in pushed screens.
struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColor.brandBlue)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
