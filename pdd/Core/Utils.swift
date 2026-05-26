//
//  Utils.swift
//  pdd
//

import SwiftUI

// MARK: - Color from hex string

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r, g, b, a: Double
        switch s.count {
        case 8: // RRGGBBAA
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        default: // RRGGBB
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Stable hashing (deterministic question selection)

/// FNV-1a 32-bit hash — used to pick a stable question window per task id.
func fnv1a32(_ s: String) -> UInt32 {
    var h: UInt32 = 2166136261
    for byte in s.utf8 {
        h ^= UInt32(byte)
        h = h &* 16777619
    }
    return h
}

// MARK: - Bundle JSON loading

extension Bundle {
    func decodeJSON<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let url = url(forResource: filename, withExtension: nil) ??
                        url(forResource: (filename as NSString).deletingPathExtension,
                            withExtension: (filename as NSString).pathExtension)
        else { fatalError("Missing bundled resource \(filename)") }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(filename): \(error)")
        }
    }
}

// MARK: - Time formatting

func formatMMSS(_ seconds: Int) -> String {
    let m = max(0, seconds) / 60
    let s = max(0, seconds) % 60
    return String(format: "%02d:%02d", m, s)
}
