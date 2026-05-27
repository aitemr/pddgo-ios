//
//  Theme.swift
//  pdd
//
//  Design tokens. Palette follows the Figma redesign, augmented with the
//  named colors from the production spec.
//

import SwiftUI

enum AppColor {
    // Brand
    static let brandBlue   = Color(hex: "#1B8FEF")
    static let brandBlue2  = Color(hex: "#3BA3F8")
    static let purple      = Color(hex: "#8A38F5")
    static let purpleAccent = Color(hex: "#A074FD")
    static let purpleDark  = Color(hex: "#7254F5")

    // Surfaces
    static let appBg       = Color(hex: "#FAFAFA")
    static let lightBg     = Color(hex: "#F2F2F7")
    static let cardBorder  = Color(hex: "#E4E4E4")
    static let navBorder   = Color(hex: "#E0E0E0")
    static let divider     = Color(hex: "#ECECEC")
    static let lockGrey    = Color(hex: "#E3E3E3")

    // Text
    static let textBlack   = Color(hex: "#303030")
    static let greyText    = Color(hex: "#979797")
    static let tabInactive = Color(hex: "#AAAAAA")

    // Semantic
    static let greenSuccess = Color(hex: "#27C46B")
    static let greenCorrect = Color(hex: "#1E8513")
    static let redError     = Color(hex: "#EF2326")
    static let redBg        = Color(hex: "#FFE4E4")
    static let orange       = Color(hex: "#FCB614")
}

extension Font {
    /// System font with the rounded design — matches "SF Pro Rounded".
    static func app(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension View {
    /// Matches the Flutter app's letter-spacing of −3 % of the font size.
    func appKerning(_ size: CGFloat) -> some View { tracking(-0.03 * size) }
}

enum AppAnimation {
    /// Snappy spring for view-state changes (selection, option tiles).
    static var snappy: Animation? {
        Session.shared.animationsEnabled ? .spring(response: 0.28, dampingFraction: 0.78) : nil
    }
    /// Smoother spring for page-level transitions (question paging).
    static var page: Animation? {
        Session.shared.animationsEnabled ? .spring(response: 0.45, dampingFraction: 0.86) : nil
    }
}

enum AppLayout {
    static let homeMargin: CGFloat = 30
    static let onboardingMargin: CGFloat = 24
    static let profileMargin: CGFloat = 20
    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 16
    static let pillRadius: CGFloat = 50
    static let designWidth: CGFloat = 440
    static let tabBarHeight: CGFloat = 84
}
