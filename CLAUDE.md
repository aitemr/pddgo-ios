# PDD KZ — Claude Code guide

iOS app for studying & passing the Kazakhstan driver's license theory exam (ПДД РК). SwiftUI, iOS 17+, single app target. Russian is the primary content/UI language; Kazakh and English are partial.

> **Read this first when starting a new task.** It captures the architectural decisions and conventions that aren't obvious from the code alone.

---

## How to work in this repo

### Build
- Open `pdd.xcodeproj` in Xcode and build. There is no SPM / Tuist / xcodegen — the `.pbxproj` is the source of truth.
- Per-file diagnostics are fast and reliable: use `XcodeRefreshCodeIssuesInFile` to validate compile correctness without a full build.
- A full project build can be slow and is sometimes blocked by in-flight package work (see *Known issues* below).

### Workflow for non-trivial features
Adopt the planning flow from `ai_feature_planning_flow.html` (the user's reference doc):

1. **Investigate first.** Read affected code, list affected files/systems. No code yet.
2. **Write a `.md` plan** in `docs/plans/<feature>.md` covering: goals, context, affected files, phases, risks, open questions, manual checks, doc updates.
3. **Stop and get sign-off** before implementing (optionally route to Codex / GPT Pro for a second opinion).
4. **Implement** with progress checkboxes inside the plan.
5. **Validate** UI manually and update docs.

For trivial fixes (one-file edits, obvious bugs), skip the plan — but still validate per-file diagnostics.

### Things to never do
- Don't aggressively modify `pdd.xcodeproj/project.pbxproj` during multi-agent sessions — collisions are very likely. Bias toward changes that only touch Swift source files.
- Don't auto-detect to system locale for `Session.language` — see *Localization* below for why.
- No `try!` / force-unwrap in production paths. No Combine — use `async/await`.
- Don't recreate widget / extension targets without coordination — the Firebase work is currently churning the project file.

---

## Architecture

```
pdd/
  App/           — Entry point, AppState, RootView, MainTabView (custom tab bar)
  Core/          — Cross-cutting: Models (Codable JSON model), Theme, Storage,
                   Strings (L enum), Localization (Localizer), Constants, Utils
  Data/          — Persistent stores (ProgressStore, StreakStore, MistakesBank,
                   Favorites, TestHistory, UsageLimits, QuestionBank, QuizCatalog)
  Features/      — One folder per top-level feature (Akzhol, Home, Onboarding,
                   Paywall, Profile, Quiz, QuizResults, Tests, VideoLessons)
  Services/      — AkzholService (cloud AI), OnDeviceAkzhol (Foundation Models),
                   SoundEffects, PushService (haptics+APNs), AuthService,
                   FirebaseAuthService, SharedStorage, WidgetSnapshot, Session,
                   SubscriptionGate
  Shared/        — Reusable UI: Components.swift, PhotoPicker.swift
  Resources/     — pdd_questions.json (question bank), assets, etc.
```

### Key state objects (all `@Observable` singletons)
- `Session.shared` — current user, language, settings toggles (`hapticsEnabled`, `animationsEnabled`, `soundEnabled`, `notificationsEnabled`)
- `ProgressStore.shared` — global correct/answered counters + per-task progress
- `StreakStore.shared` — daily streak counter (current/longest/lastActiveDay + week fires)
- `MistakesBank.shared` — set of question IDs the user got wrong
- `Favorites.shared` — favorited question IDs
- `TestHistory.shared` — trial exam attempt log
- `UsageLimits.shared` — free-tier gates (Akzhol turns, per-quiz/per-lesson)
- `AppState.shared` — selected tab + auth flow

Views observe via `@State private var session = Session.shared` style — SwiftUI Observation, **not Combine**.

---

## Key systems

### Localization (UI strings)
- All UI strings live in `Core/Strings.swift` as the `L` enum.
- `Core/Localization.swift` defines `Localizer.pick(ru:kk:en:)`. It reads `Session.shared.language` and returns the matching variant, falling back to `ru` when a translation is missing.
- **Migration is partial.** ~45 high-visibility strings are migrated (nav, quiz buttons, profile, settings, akzhol, common). The rest are still ru-only `static let`. Adopt the `Localizer.pick(...)` pattern when touching strings.
- `Session.language` **defaults to `.ru`** (not system locale) because most strings haven't been translated yet — system-locale defaulting produced mixed-language UI when the device was English.
- Question content (`PddQuestion.localizedQuestion(_:)` / `PddAnswer.localized(_:)`) reads ru/kk/en fields from `pdd_questions.json`. New EN fields are `questionENG` / `answerDescENG` / `answerENG`, all decoded with `decodeIfPresent` so legacy JSON still works.

### Storage
- Two layers: `Store` (standard `UserDefaults` wrapper, in `Core/Storage.swift`) and `SharedDefaults` (in `Services/SharedStorage.swift`).
- `SharedDefaults.current` uses the App Group suite `group.com.zimran.pdd` when configured, otherwise falls back to standard defaults. This is forward-prep for the widget extension — until the App Group capability is added in Xcode, it's a no-op transparent fallback.
- `StreakStore` and `WidgetSnapshot` write through `SharedDefaults`. Everything else uses `Store`.

### Akzhol AI (chat assistant)
- `AkzholService.shared.reply(history:lang:)` is the single entry point used by `ChatViewModel`.
- Provider chain:
  1. **On-device (Foundation Models)** — preferred when iOS 26+, Apple Intelligence available, and **no images** in history. See `OnDeviceAkzhol.swift`.
  2. **Cloud (Gemini)** — used when on-device is unavailable, when images are attached (FM is text-only), or as a fallback on any on-device failure. Needs `GEMINI_API_KEY` in `Info.plist`.
- Persona prompt (Akzhol = traffic police officer) is defined identically in both providers.
- Image messages always go to cloud (`AkzholService.body` builds Gemini-format `inline_data` parts).

### Quiz flow
- `QuizFlowView` → `QuizPage` (question UI) → `ResultsView` / `CompletionView` (`StreakView`).
- `QuizViewModel` is `@Observable`. State machine: pick → submit → next. Replay mode skips persistence.
- On submit: haptic feedback (`Haptics.notify`) + sound (`SoundEffects.play(.correct/.wrong)`) gated by `Session` toggles.
- On finish (non-replay): `StreakStore.recordActivity()` + `WidgetSnapshot.write()` + records into `ProgressStore` / `TestHistory` / `MistakesBank` as appropriate.
- Animation: question container has `.id(currentIndex)` + asymmetric slide+fade `.transition`. Option tiles use `.symbolEffect(.bounce)` on resolve. All animations gated by `AppAnimation.snappy` / `AppAnimation.page` which respect `Session.animationsEnabled`.

### Streak + Widget snapshot
- `StreakStore` — fire days within current ISO week, current streak, longest streak. Updated once per day after any quiz finish.
- `WidgetSnapshot` — Codable bundle of progress + streak, written to `SharedDefaults` after every quiz finish.
- **Widget target is deferred.** The data layer is ready; adding the WidgetKit extension target requires significant `.pbxproj` work that should not collide with the Firebase work in progress.

### Sound + Haptics + Animations
- `SoundEffects.play(.correct/.wrong)` — uses bundled `sfx_correct.caf` / `sfx_wrong.caf` if present, else iOS system sound IDs 1025 / 1053. Toggled by `Session.soundEnabled`.
- `Haptics.impact()` / `Haptics.notify(.success/.error)` — gated by `Session.hapticsEnabled`.
- `AppAnimation.snappy` / `AppAnimation.page` — return `Animation?` (nil disables) based on `Session.animationsEnabled`.

---

## Conventions

- **SwiftUI only**, no UIKit views in feature code (UIKit allowed for narrow needs: `PhotoPicker`, `CameraPicker`).
- **No Combine.** Use `async / await` and `@Observable` (Observation framework).
- **PascalCase** types, **camelCase** properties/methods, 4-space indent.
- Colors via `AppColor.foo` (`Core/Theme.swift`) or `Color(hex: "#...")` for one-offs.
- Fonts via `.font(.app(size, weight))` — SF Pro Rounded.
- Strings via `L.foo` (`Core/Strings.swift`). When adding new strings, prefer `static var foo: String { Localizer.pick(ru:..., kk:..., en:...) }`.
- Tests use the `Testing` framework (Swift Testing); UI tests use `XCUIAutomation`.
- Comments: only when the *why* is non-obvious. Don't restate what the code says.

---

## Known issues / WIP

- **Firebase auth integration is in flight** by another agent. Untracked files: `Info.plist`, `pdd.entitlements`, `GoogleService-Info.plist`, `Services/FirebaseAuthService.swift`. The `.pbxproj` is modified to add Firebase + GoogleSignIn SPM packages. Build currently fails with `Missing package product 'FirebaseCore' / 'FirebaseAuth' / 'GoogleSignIn'` until package resolution completes. Don't touch these files.
- **UI string migration is partial.** Most strings in `Core/Strings.swift` are still ru-only `static let`. Migrate incrementally to the `Localizer.pick(...)` pattern.
- **Question bank EN translations** need to be generated. The user has a Python script (`gemini-code-*.py` in their Downloads) that adds `questionENG` / `answerDescENG` / `answerENG` fields. Drop the resulting JSON into `Resources/pdd_questions.json` to enable EN.
- **Widget target not created.** Data layer ready (`WidgetSnapshot`, `StreakStore`, `SharedDefaults`). Add the WidgetKit extension target + App Group capability once the Firebase pbxproj churn settles.
- **Sound assets not bundled.** `SoundEffects` ships with system-sound fallback. Drop `sfx_correct.caf` / `sfx_wrong.caf` into the bundle when proper assets are available.

---

## Glossary

- **ПДД** — правила дорожного движения (road traffic rules).
- **РК** — Республика Казахстан (Republic of Kazakhstan).
- **Акжол / Ақжол** — the AI assistant persona (a traffic police inspector).
- **Trial exam** — `TrialExam.standard` (40 random questions) or `TrialExam.individual` (mistakes-based).
- **спецЦОН** — the real-world testing center where users take the actual exam.
