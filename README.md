# Yoga Epic

An iOS yoga companion built with **SwiftUI**, **SwiftData** and on-device **Vision** pose tracking.

## Features

- 🧘 **AI pose coach** — real-time skeleton tracking with `VNHumanBodyPoseObservation`, per-pose joint-angle analysis, spoken feedback and a hold timer.
- 📚 **Programs & courses** — multi-day flows persisted with SwiftData.
- 🌬️ **Breathing coach** — guided box / deep / fire breathing with haptics and ambient audio.
- 🔥 **Quests & achievements** — streaks, badges and challenges.
- 📈 **Progress** — persisted history, streaks and a weekly activity chart.
- ❤️ **HealthKit** — mindful minutes and yoga workouts.
- 🌍 **Localization** — English (base) and Russian via a String Catalog.

## Tech stack

| Area | Choice |
|------|--------|
| UI | SwiftUI, `@Observable` |
| Persistence | SwiftData (courses) + Codable/UserDefaults (progress) |
| Vision | `Vision` body-pose detection |
| Backend | Firebase (Auth, Firestore) — optional via `#if canImport` |
| Analytics | Firebase Analytics / Crashlytics — optional via `#if canImport` |

## Architecture

- **`AppState`** — single `@Observable` source of truth for user progress (replaces the old `YogaAppState` + `AppStateManager`). All progress is persisted and survives restarts.
- **`YogaLibrary`** — static content (poses, breathing patterns, quests) keyed by stable identifiers.
- **`YogaPoseAnalyzer`** — pluggable `YogaPoseAlgorithm` per pose, resolved by stable pose key.
- **`Localization.swift`** — `L(_:_:)` helper for dynamic / formatted strings; static UI strings are localized automatically by SwiftUI against `Localizable.xcstrings`.

## Getting started

1. Open `Yoga1.xcodeproj` in Xcode 16+.
2. Add your own `GoogleService-Info.plist` (it is **git-ignored** — never commit it).
3. Build & run the `Yoga1` scheme on an iOS 17+ device or simulator.
   (The AI camera coach requires a physical device.)

## Localization

Strings live in `Yoga1/Localizable.xcstrings` (English source + Russian).
The development region is English. To add a language, add it to the catalog in Xcode.

## Tests

Unit tests for the geometry helpers and pose algorithms live in `Yoga1Tests/`.
They are not yet wired to a test target — add a **Unit Testing Bundle** target named
`Yoga1Tests` in Xcode and include this folder to run them.
