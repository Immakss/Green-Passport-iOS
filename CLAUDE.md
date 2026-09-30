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

## Configuration & secrets

- `Green Passport/GoogleService-Info.plist` (committed, like Android's `google-services.json` — it is client config, not a secret). Without it the app builds and shows `FirebaseMissingScreen` instead of crashing (`FirebaseBootstrap.configure()` in `GreenPassportApp`).
- Google sign-in needs the plist's `REVERSED_CLIENT_ID` as a URL scheme: set the `GOOGLE_REVERSED_CLIENT_ID` build setting in the target; `Config/Info.plist` substitutes it into `CFBundleURLTypes`. Until it is set, `GoogleSignInProvider` reports `googleUnavailable` instead of letting GoogleSignIn crash.
- Sign in with Apple: entitlement in `Config/GreenPassport.entitlements`; the Apple provider must be enabled in Firebase Auth.
- `Config/` holds files that must not be bundled (Info.plist, entitlements); it sits outside the synchronized `Green Passport/` group on purpose.

## Architecture

Three layers under `Green Passport/`, with a strict dependency direction `presentation → domain → data`:

- **`data/`** — Firebase and local implementations. `remote/FirestoreCollections` is the single source of collection paths (everything lives under `apps/greenpassport/…`, like Android). Repositories map documents by hand with `private static let field…` keys; field names must match Android's `scripts/seed-firestore.js`. Timestamps are epoch millis (`EpochMillis`), enums are stored as their Android case names (`rawValue`). Realtime listeners are wrapped into `AsyncThrowingStream` by `FirestoreStream` (the listener is removed in `onTermination`). `auth/FirebaseAuthRepository` maps `AuthErrorCode` to `AuthFailure` exactly like Android's `FirebaseAuthRepository`. `local/` holds UserDefaults-backed settings (keys match Android's DataStore keys).
- **`domain/`** — `models/` (one type per file, `nonisolated` value types), `repositories/` (protocols), `moderation/` (`WordListTextModerator`, a 1:1 port of Android's, word lists in `Resources/*.txt` — keep them in sync with `core/src/main/res/raw/`), `usecases/<feature>/` (one class per file with a single `execute` method).
- **`presentation/`** — `components/` (the design system), `navigation/`, and one folder per feature with `ui/`, `viewmodels/`, `states/`.

### Dependency injection

`di/AppDIContainer.swift` is the single composition root: every Firebase client, repository and shared use case is a `private lazy var`, and the `extension AppDIContainer` exposes `buildXViewModel()` factories. There is no DI framework. The container is created in `GreenPassportApp` only when Firebase is configured and is passed down to routes explicitly.

### Presentation pattern

- ViewModels are `@Observable final class`, hold collaborators as `@ObservationIgnored private let`, and expose `private(set) var uiState`. Forms use a struct state (`AuthUiState`); data screens use an enum (`.loading` / `.success(data:)` / `.error`).
- Work never starts in `init`. Streams are consumed in `func observe() async`, started from the route's `.task { await viewModel.observe() }`, so they are cancelled when the view goes away (the equivalent of Android's `WhileSubscribed`). Switching to a new inner stream per session is done by cancelling a stored `Task` (see `RootViewModel`).
- Each screen has **two** views: `XRoute` owns the ViewModel (`@State`, built by the container) and `XScreen` is a pure view taking plain data plus closures or a `XUserAction` enum, with a `#Preview`. Screens take no ViewModel.

### Navigation

`MainTabView` has four tabs (Home, Shop, Map, Favorites — same order as Android). Each tab is a `TabStack`: its own `NavigationStack` bound to a `TabRouter` (`@Observable`, `path: [AppDestination]`) that is put into the environment. Routes push with `@Environment(TabRouter.self)`, screens never see the router. Every pushable screen is a case of `AppDestination` and is resolved in one place, `AppDestinationView` — add new screens there. Details that open from several places (task, event, later map point) are sheets with `.presentationDetents([.medium, .large])`, attached through `View.taskDetailSheet(item:container:onDismiss:)` / `eventDetailSheet(...)`; the presenting route refreshes in `onDismiss` (Android refreshes on resume). Profile opens from the avatar in the Home toolbar; Edit profile is a `fullScreenCover` with `ProfileSetupRoute(isEditing: true)`.

The domain task model is `EcoTask` (not `Task`, which would shadow Swift Concurrency's `Task`).

### Local data & notifications

- UserDefaults (`data/local`): `onboarding_seen`, `notifications_enabled` (default true), `saved_map_point_ids` — same keys as Android's DataStore / `LocalSettingsStore`.
- SwiftData (`LocalStore.makeContainer()`): `GameProgressRecord` (best score per game, like Android's Room `game_progress`) and `NotificationLogRecord` (the in-app notification log). Repositories use the container's `mainContext`.
- Notifications are local only (`UNUserNotificationCenter`): `LocalRewardNotifier` fires after a reward callable returns points or XP, `LocalNotificationReminderScheduler` schedules `event_reminder_<eventId>` one hour before an event. Both write to the log and respect the `notifications_enabled` switch; permission is requested on first use, never at launch. `AppDelegate` shows banners while the app is in the foreground. Reminders are logged at scheduling time with their fire date; the Notifications screen shows only entries whose date has passed.

### App start

`RootRoute` switches on `RootViewModel.state` (`AppStartState`): loading → onboarding → auth → profile setup → `MainTabView`. Same rules as Android `MainViewModel`: anonymous users skip the profile wizard, a missing `profileCompletedAt` means the wizard is shown, a profile read error counts as complete. `ProfileSetupRoute(isEditing:)` is reused for "Edit profile".

## Build & run

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

The simulator is named `iPhone 17 Simulator` (not `iPhone 17`). There is **no test target and no linter configured**, so there is no `test` or `lint` command. Do not invent one; verify changes by building and by running the app on the simulator (`xcrun simctl install booted <app>`, `xcrun simctl launch booted com.smartcity.greenpassport`, `xcrun simctl io booted screenshot <file>`).

## Conventions

- Theming: never hardcode colors, fonts or spacing. Colors are color sets in `Assets.xcassets` with the same names as Android's `theme/Color.kt` tokens (`Forest`, `Lime`, `MintSurface`, `SectionCommunity`, …) and are read through `Palette` / `SectionColor`; sizes come from `Spacing` and `CornerRadius`. Backgrounds are the system grouped colors; colour comes from one green palette only — `Forest` for actions and icons, `MintSurfaceHigh` for tile backgrounds (`MintSurface` is too close to the grouped background) (`SymbolTile` styles `.accent` / `.prominent` / `.muted`), `Lime` only for points and the XP bar. `SectionColor` is not used in the UI except for the waste-sorting bins and avatar colors. The app follows the system appearance; both light and dark are supported.
- Strings: `Localizable.xcstrings` has `STRING_CATALOG_GENERATE_SYMBOLS` on, so every key is a typed `LocalizedStringResource` symbol (`Text(.completeTask)`, `Text(.level(3))`, `String(localized: .home)`). Add a key with ru, be and en values at once; format placeholders are positional (`%1$lld`, `%2$@`) like Android.

- Swift concurrency: the target builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` (Swift 5 language mode). Background types are explicitly marked `nonisolated`, `actor`, or `Sendable`.
- Files are added to the target automatically (Xcode file-system-synchronized group `Green Passport/`) — creating a file under it is enough, no `project.pbxproj` edit needed. Files that must **not** be bundled (Info.plist, entitlements) live in `Config/`, outside the synchronized group.
- Naming: this is a port of an Android app, so avoid carrying Compose/Material vocabulary back in. No `Gp` prefix, no `Scaffold`, `Dimens`, `Chip`, `Widget` in type names; no `containerColor`/`contentColor`/`elevation` parameters; no `XxxDefaults` constant holders; no SCREAMING_SNAKE constants; no `get`-prefixed accessors.
- Icons: SF Symbols only. The only imagesets are `mascot` (the character, same art as Android `mascot.webp`), `event_placeholder` and `AppIcon`.
- Fonts: San Francisco through Dynamic Type text styles (`.largeTitle`, `.headline`, `.subheadline`, …). No custom fonts, no fixed point sizes.

## Known limitations

- No push: Android only stores an FCM token and handles no incoming pushes, so the iOS app does not integrate FCM/APNs.
- The QR scanner (`DataScannerViewController`) and the camera do not work on the Simulator; the task sheet shows `qr_scanner_unavailable_msg` and hides "Take photo" there.
- The language is chosen in the system Settings (per-app language); the profile row only opens them.
