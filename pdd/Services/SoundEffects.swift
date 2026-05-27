//
//  SoundEffects.swift
//  pdd
//
//  Lightweight quiz feedback sounds, gated by the session toggle.
//  Prefers bundled .caf/.wav assets when present, falls back to iOS
//  system sound IDs so the feature works without audio assets.
//

import Foundation
import AVFoundation
import AudioToolbox

enum SoundEffects {
    enum Cue: String {
        case correct, wrong

        /// Bundled filename (without extension). Drop a matching
        /// sfx_correct.caf / sfx_wrong.caf into the bundle to override
        /// the system fallback.
        var bundledFilename: String { "sfx_\(rawValue)" }

        /// iOS system sound IDs used when no bundled asset is present.
        /// 1025 = "Tink-Tink" (positive feel), 1053 = "Tock" (negative feel).
        var systemSoundID: SystemSoundID {
            switch self {
            case .correct: 1025
            case .wrong:   1053
            }
        }
    }

    static func play(_ cue: Cue) {
        guard Session.shared.soundEnabled else { return }
        if let player = cachedPlayer(for: cue) {
            player.currentTime = 0
            player.play()
        } else {
            AudioServicesPlaySystemSound(cue.systemSoundID)
        }
    }

    // MARK: - Player cache

    private static var players: [Cue: AVAudioPlayer] = [:]

    private static func cachedPlayer(for cue: Cue) -> AVAudioPlayer? {
        if let cached = players[cue] { return cached }
        let exts = ["caf", "wav", "mp3", "m4a"]
        for ext in exts {
            if let url = Bundle.main.url(forResource: cue.bundledFilename, withExtension: ext),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                players[cue] = player
                return player
            }
        }
        return nil
    }
}
