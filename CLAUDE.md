# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Green Passport ("Зелёный паспорт") — a SwiftUI iOS app that rewards eco-friendly actions with points and XP. It is a port of the Android app in `~/Personal/greenpassport-android` and shares its Firebase backend (project `chatroom-85fb8`: Auth, Firestore, Cloud Functions in `europe-central2`, Storage). Single app target `Green Passport`, bundle id `com.smartcity.greenpassport`, iPhone only, portrait, iOS deployment target 26.5. Dependencies are SwiftPM only, resolved via the `.xcodeproj` (no workspace, no Podfile).

The Android repo is the reference for business logic: Firestore field names, callable names, reward rules, validation. When porting a feature, read the matching Android module first (`feature/<name>` and `core`), and keep behaviour identical unless `claude/ux-spec.ru.md` records a deliberate difference.

## Team Conventions

### Files
Save all Claude-generated documents (plans, review summaries, task lists) in the `claude/` folder at the repo root. Plans must be written in Russian and saved as `claude/<topic>-plan.ru.md`. Write the plan file into `claude/` as the **first** action after a plan is approved, before any code is touched. A plan that only exists in the chat is not delivered.

### Plan content
Every plan must be self-explanatory. For each meaningful step, state **why** the change is needed and show a **code example** of the resulting code, not a prose description of it. Code examples follow the same rules as production code. A plan ends with a **verification** section listing the build command and the manual scenarios that prove the feature works end to end.

### Commit Messages
Every commit message follows this structure:

```
Short summary of the feature(s) in general terms

- First feature in one sentence
- Second feature in one sentence
```

The first line is a general one-line description of what the commit does, followed by a blank line and a bullet list where each bullet describes one feature/change in a single sentence. Omit the bullet list only when the commit truly contains a single change already covered by the summary line.

Never mention Claude, Anthropic, or any AI assistant in a commit message or pull request — no `Co-Authored-By: Claude`, no "Generated with Claude Code", no trailers or footers of any kind referencing them.

### Mindset
Do not be a yes-man. If a proposed approach has problems, say so and explain the trade-off before implementing. State your position first; implement what the user decides after the discussion.

### Swift Code Rules

**One type per file:** Every `class`, `struct`, `enum`, `protocol`, and `actor` lives in its own file named after the type. The only exceptions are small private helper types used exclusively by one other type in the same file.

**No comments:** Do not write any comments in Swift source files — no `//`, no `/* */`, no doc comments (`///`, `/** */`). Self-documenting names are the only acceptable form of documentation.

**Named constants:** All numeric limits (timeouts, counts, thresholds, sizes, weights, etc.) must be a `private static let` (or a `private` constant in the owning type). Never write a raw number inline where the value carries meaning.

**Explicit `return`:** Always write `return` in non-`Void` functions and closures, even when Swift allows single-expression implicit returns. Applies to computed properties, single-statement function bodies, and trailing closures alike. SwiftUI `body` and `@ViewBuilder` bodies are the exception — they are builders, not returns.

**Localization:** Never hardcode user-facing strings. Every string shown in the UI goes through `Resources/Localizable.xcstrings` via `String(localized:)` / SwiftUI's automatic `Text` localization. Source language is Russian; every key also gets `be` and `en` translations. Keys are the Android `strings.xml` `name`s (`complete_task`, `sign_in_to_earn_points_msg`) so both platforms share one vocabulary: the key mirrors the English content, lowercased and snake_cased, no category prefixes, long texts take the first words plus `_msg`.

## UX parity with Android

The Android and iOS apps share one UX: the same tabs, entry points, step order, texts, colors, rules and loading/empty/error states. Controls are native to each platform (HIG here, Material 3 on Android) — parity is about flows, not pixels.

`claude/ux-spec.ru.md` is the platform-neutral source of truth (the same file lives in the Android repo's `claude/`). **Any UX change goes into the spec first, then into code.** A behaviour difference that is not recorded in the spec is a bug. Deliberate iOS-first changes that Android must adopt go into the spec's "Android backlog" section.

## Build & run

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

The simulator is named `iPhone 17 Simulator` (not `iPhone 17`). There is **no test target and no linter configured**, so there is no `test` or `lint` command. Do not invent one; verify changes by building and by running the app on the simulator (`xcrun simctl install booted <app>`, `xcrun simctl launch booted com.smartcity.greenpassport`, `xcrun simctl io booted screenshot <file>`).

## Conventions

- Swift concurrency: the target builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` (Swift 5 language mode). Background types are explicitly marked `nonisolated`, `actor`, or `Sendable`.
- Files are added to the target automatically (Xcode file-system-synchronized group `Green Passport/`) — creating a file under it is enough, no `project.pbxproj` edit needed. Files that must **not** be bundled (Info.plist, entitlements) live in `Config/`, outside the synchronized group.
- Naming: this is a port of an Android app, so avoid carrying Compose/Material vocabulary back in. No `Gp` prefix, no `Scaffold`, `Dimens`, `Chip`, `Widget` in type names; no `containerColor`/`contentColor`/`elevation` parameters; no `XxxDefaults` constant holders; no SCREAMING_SNAKE constants; no `get`-prefixed accessors.
- Icons: SF Symbols only. The only imagesets are `mascot` (the character, same art as Android `mascot.webp`), `event_placeholder` and `AppIcon`.
- Fonts: San Francisco through Dynamic Type text styles (`.largeTitle`, `.headline`, `.subheadline`, …). No custom fonts, no fixed point sizes.
