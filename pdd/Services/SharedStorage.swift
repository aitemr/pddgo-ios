//
//  SharedStorage.swift
//  pdd
//
//  Wraps UserDefaults with an optional App Group suite. The widget extension
//  (to be added in a future PR) will read from the same suite to display
//  progress + streak without touching the main app.
//
//  To enable cross-process sharing later:
//    1. Add an App Group capability with id `group.com.zimran.pdd` to both
//       the app target and the widget extension target.
//    2. `AppGroup.id` is already set below; no code changes needed.
//

import Foundation

enum AppGroup {
    /// Set this to your registered App Group id. Until the capability is
    /// added in Xcode, calls fall back to `UserDefaults.standard`.
    static let id = "group.com.zimran.pdd"
}

enum SharedDefaults {
    /// Returns the App Group defaults if available, otherwise the standard
    /// store. Reads and writes work in both modes.
    static var current: UserDefaults {
        UserDefaults(suiteName: AppGroup.id) ?? .standard
    }
}
