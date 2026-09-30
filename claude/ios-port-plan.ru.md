# Перенос Green Passport с Android на iOS (SwiftUI)

## Контекст

В iOS-репозитории `Green-Passport-iOS` сейчас только заготовка. Файлы в `Green Passport/Views`, `Models` и `Resources` либо пустые, либо содержат одну шапку-комментарий. `ContentView.swift` удалён, хотя `Green_PassportApp` на него ссылается, поэтому проект не собирается. В корне лежат дубли папок `App/` и `Views/`. Также есть шрифт Capriola, который не нужен, потому что шрифт — San Francisco.

Рабочее приложение существует на Android (`~/Personal/greenpassport-android`): примерно 13 тыс. строк Kotlin, модуль `:core` и 12 фич-модулей, бэкенд на Firebase (проект `chatroom-85fb8`: Auth, Firestore, Functions `europe-central2`, Storage).

Задача — перенести на iOS логику и все экраны. Требования:
- шрифт SF, иконки SF Symbols, соответствие Human Interface Guidelines;
- дизайн — нативный минимализм iOS плюс краски Android: лесной зелёный, лаймовый и цвета разделов. Потом по этому дизайну обновим Android.

Решения пользователя:
- bundle id `com.smartcity.greenpassport`, Firebase через SPM;
- вход по email, гостевой, через Google и через Apple (правило App Review 4.8);
- карта — Apple MapKit;
- все фичи переносим поэтапно, после каждого этапа коммит.

Первое действие после одобрения — сохранить этот план в `claude/ios-port-plan.ru.md`. Правило взято из `CLAUDE.md` Android-проекта.

## Единый UX на Android и iOS

### Позиция
Единый UX — это одинаковые сценарии, а не пиксель-в-пиксель одинаковые экраны. Одинаковыми должны быть:
- структура: те же вкладки, те же точки входа, тот же порядок шагов;
- тексты: общие ключи строк;
- цвета и иконография: одни токены;
- правила: лимиты, валидации, состояния загрузки, пустого экрана и ошибки.

Контролы берём родные для каждой платформы: на iOS — HIG (large title, sheet с detents, Liquid Glass tab bar), на Android — Material 3. Если сделать Android «как iOS» или наоборот, получится приложение, которое чужеродно на обеих платформах. К тому же Apple это отмечает на ревью.

### Как держим паритет
1. **`claude/ux-spec.ru.md`** — платформо-независимая спецификация. Создаётся на этапе 0 и дополняется по фичам. Для каждого экрана в ней описано:
   - откуда открывается и куда ведёт;
   - блоки сверху вниз;
   - состояния (загрузка, пусто, ошибка);
   - ключи строк;
   - токены цвета и символ.

   В колонке «Иконка» указаны пары: SF Symbol ↔ Material icon.
   Этот же файл копируется в `greenpassport-android/claude/`, это единый источник правды.
2. **Общие токены.** Названия цветов одинаковые (`Forest`, `Lime`, `SectionCommunity`…) и совпадают с `theme/Color.kt`. Ключи строк совпадают с `name` в `strings.xml`.
3. **Журнал расхождений.** Раздел «Android backlog» в `ux-spec.ru.md`: всё, в чём iOS сознательно отходит от текущего Android, чтобы Android догнал на своём редизайне. Уже известно:
   - Sign in with Apple — добавить и на Android: Firebase поддерживает Apple через web-OAuth на Android;
   - кликабельные email, телефон и `mediaUrl`;
   - свайпы в лабиринте;
   - меню «Снять фото / Из галереи» для PHOTO-заданий (в Android сейчас только галерея);
   - подтверждение перед покупкой награды;
   - новая цветовая схема: белые или сгруппированные фоны вместо мятных, цветные квадратные плитки иконок.
4. **Язык приложения** — единственное неизбежное расхождение механики. На Android остаётся выпадающий список в профиле. На iOS строка «Язык» открывает системные настройки приложения. Сценарий одинаковый: «Профиль → Язык».
5. В CLAUDE.md обоих проектов добавляется правило: *любое изменение UX сначала вносится в `claude/ux-spec.ru.md`, затем в код; расхождение без записи в спецификации — баг.*

## Что должен сделать пользователь (параллельно с этапом 1)

1. Firebase Console → проект `chatroom-85fb8` → Add app → iOS, bundle id `com.smartcity.greenpassport`. Скачать `GoogleService-Info.plist` и положить в `Green Passport/`.
2. Authentication → Sign-in method: включить **Apple**.
3. Apple Developer, команда `62Z3NJ7UN6`: для App ID включить capability *Sign in with Apple*. Entitlement в проект добавлю сам.

Пока plist не положен, приложение собирается, но на старте показывает экран «Firebase не настроен», а не падает (см. шаг 1.3).

---

## Этап 0. CLAUDE.md и чистка проекта

### Почему
`CLAUDE.md` в репозитории нет, а без него дальнейшие сессии не знают правил. Мёртвые заготовки (пустые файлы, дубли `App/` и `Views/`, Capriola) мешают собрать проект.

### Что делаем
- Удалить `App/`, `Views/` в корне, все пустые `.swift` в `Green Passport/`, а также `Capriola-Regular.ttf`.
- Переименовать ассеты: `lyasyunya` → `mascot` (это тот же маскот, что `mascot.webp` в Android), `card` → `event_placeholder`.
- `project.pbxproj`:
  - `PRODUCT_BUNDLE_IDENTIFIER = com.smartcity.greenpassport`;
  - `knownRegions = (ru, be, en, Base)`, `developmentRegion = ru`;
  - только портрет на iPhone.
  - Группа `Green Passport/` уже синхронизируется с файловой системой (`PBXFileSystemSynchronizedRootGroup`), поэтому новые файлы в pbxproj добавлять не нужно.
- Создать `CLAUDE.md`. Разделы Team Conventions (Files, Commit Messages, Mindset) и Swift Code Rules перенести из `~/Projects/scryptowallet-ios/CLAUDE.md`, адаптировать:
  - план на русском, в `claude/<topic>-plan.ru.md`, записывается первым действием;
  - в коммитах не упоминать ИИ.

  Затем добавить разделы Project, Build & run, Architecture, Theming, Conventions, UX parity. После каждого этапа дописывать то, что этот этап ввёл.
- **`.gitignore`.** В репозитории его нет, а `xcuserdata/` от первого автора (`maxtrusov.xcuserdatad/…/xcschememanagement.plist`) уже закоммичен. Решение: добавить `.gitignore` и снять этот файл с индекса командой `git rm -r --cached "Green Passport.xcodeproj/xcuserdata"`. Сам файл на диске при этом остаётся.
  ```gitignore
  .DS_Store
  xcuserdata/
  *.xcuserstate
  *.xcscmblueprint
  *.xccheckout
  DerivedData/
  build/
  *.moved-aside
  *.hmap
  *.ipa
  *.dSYM.zip
  *.dSYM
  timeline.xctimeline
  playground.xcworkspace
  .swiftpm/
  .build/
  Packages/
  fastlane/report.xml
  fastlane/Preview.html
  fastlane/screenshots/**/*.png
  fastlane/test_output
  *.xcconfig.local
  .env
  .claude/settings.local.json
  ```
  Остальное:
  - `Package.resolved` (`project.xcworkspace/xcshareddata/swiftpm/Package.resolved`) коммитим, чтобы версии SPM были зафиксированы.
  - `GoogleService-Info.plist` тоже коммитим, как `google-services.json` в Android. Это клиентский конфиг, а не секрет: доступ ограничивают правила Firestore и Storage.
- Создать `claude/ux-spec.ru.md`: общие разделы (навигация, вкладки, токены, соответствие иконок SF ↔ Material, Android backlog). Разделы экранов добавлять по мере их переноса на этапах 1–5.
- В Android-репозитории: скопировать туда `ux-spec.ru.md` и добавить в его `CLAUDE.md` правило про паритет UX. Код Android в этой задаче не трогаем, редизайн Android — отдельная задача по backlog'у.

### Build & run (пойдёт в CLAUDE.md)
```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

---

## Этап 1. Основа: архитектура, дизайн-система, старт приложения

### 1.1 Структура и архитектура

#### Почему
В Android слои разнесены по модулям (`:core` и фичи). На iOS один таргет, поэтому та же граница делается папками. Направление зависимостей — как в scryptowallet: `presentation → domain → data`. Благодаря этому команда работает по уже знакомым правилам.

#### Структура папок
```text
Green Passport/
├── app/            GreenPassportApp, AppDelegate, RootView, AppStartState
├── di/             AppDIContainer (единый composition root, lazy var + buildXViewModel())
├── data/
│   ├── remote/     FirestoreCollections, Firestore*Repository, CloudFunctionName, FirebaseRewardsRepository
│   ├── local/      SwiftData-модели (GameProgressRecord, NotificationLogRecord), SettingsStore (UserDefaults)
│   ├── auth/       FirebaseAuthRepository, GoogleSignInProvider, AppleSignInProvider
│   └── media/      JpegCompressor
├── domain/
│   ├── models/     Task, EcoEvent, EcoTip, Reward, Coupon, MapPoint, UserProfile, … (один тип на файл)
│   ├── repositories/  протоколы (TasksRepository, PointsRepository, …)
│   ├── moderation/    TextModerator, WordListTextModerator
│   └── usecases/<feature>/  по одному use case на файл с func execute(...)
├── presentation/
│   ├── navigation/ MainTabView, AppRouter, *Destination
│   ├── components/ общие вью дизайн-системы
│   └── <feature>/{ui,viewmodels,states}
├── theme/          Palette, SectionColor, Spacing, CornerRadius
└── Resources/      Assets.xcassets, Localizable.xcstrings, banned_roots.txt, allowed_words.txt
```

#### Отличия от scryptowallet (обоснование)
- **Swift Concurrency вместо Combine.**
  - Разовые запросы: `async throws` (`getDocuments()` и `HTTPSCallable.call` в Firebase SDK уже асинхронные).
  - Realtime-слушатели: `AsyncThrowingStream`, который в `onTermination` снимает `ListenerRegistration`.
  - Это прямой аналог `Flow` из Android, поэтому логика переносится один в один.
- **Подписка через `.task`, без запуска работы в `init`.** Это аналог правила Android «никаких `init {}`, только `WhileSubscribed`». Загрузка стартует в `.task { await viewModel.observe() }` и отменяется, когда вью исчезает.

```swift
@Observable
final class TasksListViewModel {
    @ObservationIgnored private let fetchTasks: FetchTasksUseCase
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    private(set) var uiState: TasksListUiState = .loading

    init(fetchTasks: FetchTasksUseCase, observeSession: ObserveSessionUseCase) {
        self.fetchTasks = fetchTasks
        self.observeSession = observeSession
    }

    func observe() async {
        for await session in observeSession.execute() {
            do {
                let tasks = try await fetchTasks.execute()
                uiState = .success(data: TasksListUiData(tasks: tasks, userId: session?.userId))
            } catch {
                uiState = .error
            }
        }
    }
}
```

#### Правила для экранов (как в scryptowallet)
- На каждый экран два вида вью:
  - `XRoute` владеет ViewModel и переключается по `uiState`;
  - `XScreen` — чистая вью: принимает данные и замыкания, содержит `#Preview`.
- Действия пользователя передаются наверх замыканиями.

### 1.2 Firebase и SPM

#### Почему
Весь бэкенд — это Firebase. Очки начисляют только Cloud Functions, клиенту писать `availablePoints` запрещено.

#### Что подключаем
- SPM `firebase-ios-sdk`: FirebaseAuth, FirebaseFirestore, FirebaseFunctions, FirebaseStorage.
- SPM `GoogleSignIn-iOS`.
- `Functions.functions(region: "europe-central2")`.
- Имена callable-функций переносятся в `enum CloudFunctionName: String`.
- Маппинг ошибок `FunctionsErrorCode` → `RewardFailure` делается один в один с Android `toRewardFailure`.

```swift
nonisolated enum FirestoreCollections {
    private static let root = "apps/greenpassport"
    static let users = "\(root)/users"
    static let tasks = "\(root)/tasks"
    static let taskProgress = "\(root)/taskProgress"
    static func chatMessages(chatId: String) -> String {
        return "\(root)/chats/\(chatId)/messages"
    }
}
```

#### Правила маппинга
Поля документов маппятся вручную через `private static let` ключи — так же, как `FIELD_*` в Android. Имена полей должны совпадать с `scripts/seed-firestore.js`. Время хранится в epoch millis (`Int64`), enum — в виде `rawValue` = имя кейса из Android.

### 1.3 Старт приложения

#### Почему
Android выбирает стартовое состояние (`AppStartupState`): онбординг → вход → анкета → главная. Без этого нельзя попасть ни на один экран.

#### Код
```swift
enum AppStartState {
    case loading
    case firebaseMissing
    case needsOnboarding
    case needsAuth
    case needsProfile
    case ready
}
```
- `RootViewModel` объединяет `onboardingSeen` (UserDefaults) и статус профиля. Логика как в `MainViewModel` Android: гость → анкета пропускается; ошибка профиля → считается COMPLETE.
- `firebaseMissing` включается, если в бандле нет `GoogleService-Info.plist`.

### 1.4 Дизайн-система: iOS-минимализм + краски Android

#### Почему
Пользователь просит сохранить минимализм iOS и добавить цвет Android. Принцип: **структура и поведение нативные, цвет из Android.**

| Элемент | Решение |
|---|---|
| Фон / карточки | `systemGroupedBackground` / `secondarySystemGroupedBackground`: нативная светлая и тёмная тема, без мятной заливки всего экрана |
| Акцент (tint) | `AccentColor` = Forest `#1F6B47` / тёмная тема `#2E8C5E`. Tint приложения — кнопки, переключатели, выбранная вкладка |
| Очки | капсула лаймового цвета `#C3EE5A` с `bolt.fill` (аналог `PointsChip`) |
| Иконки строк | цветной скруглённый квадрат с белым SF Symbol, как в «Настройках» iOS. Цвета разделов из Android: community `#34C77B`, games `#8E7CF0`, tips `#FF9F43`, calendar `#4DA3FF`, feedback `#FF6B8A` |
| Карточка прогресса | единственный крупный цветной блок: Forest-фон, лаймовая полоса XP, маскот и реплика (аналог `ProgressHeroCard`) |
| Навигация | нативные `NavigationStack` с large title и `TabView` (Liquid Glass iOS 26) вместо `ScreenHeader` и плавающего `GpBottomBar` |
| Детали задания / события / точки | `.sheet` с `.presentationDetents([.medium, .large])` вместо `GpSheetScaffold` |
| Фильтры | горизонтальный ряд капсул `.buttonStyle(.bordered)`/`.borderedProminent`, для 2–3 вариантов — `Picker(.segmented)` |
| Кнопки | `.buttonStyle(.glassProminent)`, `.controlSize(.large)` |
| Формы (анкета, отзывы, профиль) | `Form` / `List(.insetGrouped)` |
| Шрифт | только текстовые стили Dynamic Type (`.largeTitle`, `.headline`, `.subheadline`…), без фиксированных кеглей |
| Тактильный отклик | `.sensoryFeedback(.success, trigger:)` при начислении очков (нативно для iOS) |

#### Токены в `theme/`
- Цвета — color sets в `Assets.xcassets` с вариантами Any/Dark. Доступ через `Palette`, сырые HEX в коде запрещены.

```swift
enum Palette {
    static let forest = Color("Forest")
    static let lime = Color("Lime")
    static let onLime = Color("OnLime")
}

enum SectionColor {
    static let community = Color("SectionCommunity")
    static let games = Color("SectionGames")
    static let tips = Color("SectionTips")
    static let calendar = Color("SectionCalendar")
    static let feedback = Color("SectionFeedback")
}
```
- Размеры — в `Spacing` и `CornerRadius`.
- Компоненты в `presentation/components/`: `PointsBadge`, `SymbolTile`, `ProgressHeroCard`, `ProfileAvatar` (6 стилей `AvatarStyle`), `MascotImage`, `HeroImageCard` (фото события с градиентом), `FilterBar`, `StateView` (загрузка / пусто / ошибка с маскотом), `RemoteImage` (`AsyncImage` с плейсхолдером).
- Словарь Compose в имена не переносим, как в scryptowallet: никаких `Gp*`, `Scaffold`, `Chip`, `Dimens`.

### 1.5 Локализация

#### Почему
В Android 290 строк на трёх языках (ru по умолчанию, be, en), плюс выбор языка внутри приложения.

#### Что делаем
- `Localizable.xcstrings`, исходный язык ru, переводы be и en.
- Ключи совпадают с `name` в Android (`complete_task`, `sign_in_to_earn_points_msg`). Так строки синхронизируются между платформами.
- Строки переносятся скриптом, который читает `values*/strings.xml`. Скрипт лежит в scratchpad, в репозиторий не попадает. `%1$d` / `%1$s` → `%lld` / `%@`.
- Выбор языка: по HIG язык меняется в системных «Настройки → Green Passport → Язык». Строка «Язык» в профиле показывает текущий язык и открывает `UIApplication.openSettingsURLString`. `AppCompatDelegate` здесь не нужен.

```swift
Text("complete_task")
let message = String(localized: "points_earned_msg \(points)")
```

### 1.6 Онбординг, вход и анкета (фича auth)
- **OnboardingScreen:** маскот, заголовок, подзаголовок, кнопка «Начать».
- **AuthScreen:**
  - `Picker(.segmented)` Вход / Регистрация, поля email и пароль (`SecureField` с кнопкой показа), подтверждение пароля при регистрации;
  - кнопки `SignInWithAppleButton` и Google, «Продолжить без аккаунта».
  - Валидация как в Android: формат email, пароль от 6 символов, совпадение паролей.
  - `AuthFailure` маппится из `AuthErrorCode`; отмена Google/Apple ошибкой не считается.
- **Apple:** `ASAuthorizationAppleIDProvider` с nonce (SHA256), затем `OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)`.
- **ProfileSetupScreen:** 4 шага (имя, город из 12 `SupportedCities`, интересы `TaskCategory`, аватар из 6 `AvatarStyle`), индикатор шагов, валидация имени (2–30 символов, регулярка `^[\p{L}][\p{L} \-]*$`, `TextModerator`). Этот же экран работает для «Редактировать профиль». Сохранение — `setData(merge: true)` с `profileCompletedAt`.
- **TextModerator:** перенести `WordListTextModerator` один в один (замена похожих латинских и кириллических букв в обе стороны, склейка одиночных букв, схлопывание повторов). Списки слов копируются в `Resources/*.txt`.

**Коммит этапа 1:** `Set up the iOS app foundation, design system and sign-in flow`.

---

## Этап 2. Главная, задания, профиль

- **Вкладки `MainTabView`:** Главная (`house`), Магазин (`bag`), Карта (`map`), Избранное (`heart`). В профиль попадаем по аватару в тулбаре главной, как в Android.
- **Навигация:** один `NavigationStack` на вкладку, destinations — `Hashable`-структуры. Детали задания и события открываются через `.sheet(item:)`: это модальные карточки, в стек их не кладём.
- **HomeScreen:**
  - дата, «Привет, {имя}», `ProgressHeroCard`;
  - горизонтальный ряд быстрых действий (5 цветных `SymbolTile`);
  - ближайшее событие (`HeroImageCard`), «Ваши задания» (3 штуки, сортировка по городу и интересам — как `GetPendingTasksUseCase`).
  - Обновление через `.refreshable` и при возврате на экран.
- **TasksListScreen:** фильтры «Для вас / Все / 5 категорий», строки с `PointsBadge`, сердечко (`heart` / `heart.fill`, цвет feedback), статусы «Выполнено» и «На проверке».
- **TaskDetailSheet — три способа подтверждения:**
  - `SELF` → callable `completeSelfTask`, лимит 3 в день проверяет сервер.
  - `QR` → `DataScannerViewController` (VisionKit, `.barcode(symbologies: [.qr])`) в `UIViewControllerRepresentable`, затем `redeemTaskCode`. Если `isSupported == false`, показываем понятную ошибку. Нужен `NSCameraUsageDescription`.
  - `PHOTO` → меню «Снять фото» (камера через `UIImagePickerController`) и «Из галереи» (`PhotosPicker`). Дальше `JpegCompressor` (длинная сторона ≤ 1600, качество 0,85), загрузка в Storage `greenpassport/submissions/{uid}/{UUID}.jpg`, документ `taskSubmissions/{uid}_{taskId}`. Статус отслеживаем в реальном времени.
- **Профиль:**
  - `ProfileScreen` (`List(.insetGrouped)`): шапка с аватаром, карточка прогресса, строки с цветными `SymbolTile`, переключатель уведомлений, язык, модерация (только для админа), выход.
  - `AchievementsScreen`: 6 достижений, условия считаются на клиенте, как в `AchievementsRepositoryImpl`.
  - `CardsScreen`: `LazyVGrid` из 2 колонок.
  - `HistoryScreen`.
  - `ExchangeScreen`: заглушка, как в Android.

**Коммит этапа 2.**

---

## Этап 3. Магазин, календарь, карта, избранное
- **Shop:** баланс (`ProgressHeroCard` без уровня), каталог, покупка через `redeemReward` с подтверждением (`confirmationDialog`), история покупок. Недостаток очков проверяем на клиенте, окончательно проверяет сервер.
- **Calendar:** список `HeroImageCard`.
  - `EventDetailSheet` — регистрация (`eventRegistrations/{uid}_{eventId}`), затем локальное напоминание за час.
  - Напоминание: `UNUserNotificationCenter`, `UNCalendarNotificationTrigger`, идентификатор `event_reminder_<id>`. При срабатывании пишем в журнал уведомлений.
- **Map:**
  - SwiftUI `Map` с `Annotation` (цветной `SymbolTile` по типу точки: `storefront`, `arrow.3.trianglepath`, `calendar`);
  - `.searchable` и фильтр по типу поверх карты (`.safeAreaInset`), `MapPointSheet` с кнопкой «Сохранить»;
  - сохранённые id хранятся в UserDefaults (`saved_map_point_ids`), как в Android.
  - Разрешение на геолокацию не нужно: `UserLocationButton` не добавляем, камеру центрируем по среднему координат точек.
- **Favorites (вкладка):** `Picker(.segmented)` «Задания / Советы».

**Коммит этапа 3.**

---

## Этап 4. Сообщество, эко-советы, отзывы
- **Community:**
  - хаб из двух строк: форум и группы.
  - `ForumScreen` — realtime-лента, поле ввода через `.safeAreaInset(edge: .bottom)`, жалоба через `Menu` с 4 причинами (`reports/{postId}_{uid}`). Текст проходит `TextModerator`.
  - `GroupsScreen` — создание группы и вступление (`arrayUnion`).
- **EcoTips:** карточка «Совет дня», фильтр категорий, закладки. Детальный экран: «Прочитано» → `recordTipRead`; `mediaUrl` — кликабельная `Link` (в Android это обычный текст).
- **Feedback:** `Form` из секций «Отзыв» (5 звёзд), «Предложение», «Опрос» (один ответ), «Поддержка». Email и телефон — кликабельные `Link` на `mailto:` и `tel:`.

**Коммит этапа 4.**

---

## Этап 5. Игры, модерация, уведомления
- **Игры:**
  - хаб с 4 играми и рекордами. Рекорды хранятся в SwiftData `GameProgressRecord` (максимум).
  - Результат отправляется через `recordGameResult`, только для вошедших пользователей.
  - Правила переносятся один в один:
    - память: 6 пар, сетка 4×3, счёт = `max(10, 100 − 5·max(0, ходы − 6))`, пауза 800 мс;
    - сортировка отходов: 30 с, 8 предметов, 4 бака, +10 за правильный ответ;
    - лабиринт: 5×5 по той же раскладке, +20 за предмет;
    - викторина: 5 вопросов, +20 за правильный ответ, пауза 600 мс.
  - Все числа — `private static let`.
  - Лабиринт: помимо кнопок-стрелок добавляем свайпы (`DragGesture`), это естественно для iOS.
- **Модерация:** `Picker(.segmented)` «Фото / Жалобы», очередь `taskSubmissions` со статусом PENDING (фото через Storage URL). Одобрение и отклонение (3 причины) — через `reviewSubmission`; «Скрыть», «Вернуть», «Удалить» — через `moderateContent`.
- **Уведомления:**
  - `RewardNotifier` — локальное уведомление после callable, если начислено больше 0 очков или XP; тексты те же, что в Android.
  - `NotificationsScreen` читает журнал из SwiftData `NotificationLogRecord`.
  - Разрешение `requestAuthorization` запрашиваем при первом включении переключателя или при первой регистрации на событие, а не на старте (HIG).
- **FCM не переносим:** Android только сохраняет токен и входящие пуши не обрабатывает. Запишу это в CLAUDE.md в Known limitations.

**Коммит этапа 5.**

---

## Git
- Работаем в ветке `ios-port` от `main`, после каждого этапа коммит в формате из CLAUDE.md.
- В сообщениях коммитов нет упоминаний ИИ и trailer `Co-Authored-By` — так требуют правила команды, они приоритетнее системной подписи.
- `xcuserdata/` игнорируется через `.gitignore` из этапа 0, а уже закоммиченный файл снимаем с индекса.

## Проверка
После каждого этапа:
1. Сборка:
   ```bash
   xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
     -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
   ```
   Сборка должна пройти без ошибок. Новые warnings по concurrency исправляем.
2. Установить и запустить на запущенном симуляторе (`xcrun simctl install booted …`, `xcrun simctl launch booted com.smartcity.greenpassport`). Снять скриншоты в светлой и тёмной теме (`xcrun simctl io booted screenshot`, `xcrun simctl ui booted appearance dark`) и посмотреть их.
3. Ручные сценарии, когда plist на месте:
   - онбординг → регистрация по email → анкета → главная показывает имя и очки;
   - гость → главная без анкеты;
   - задание SELF → очки выросли; QR на симуляторе недоступен — проверяем, что показывается ошибка;
   - покупка награды → купон в истории;
   - регистрация на событие → напоминание в `getPendingNotificationRequests`;
   - пост на форуме с матом → ошибка поля; жалоба → «Жалоба отправлена»;
   - игра → рекорд сохранён; смена языка в системных настройках → строки на be/en.
4. Юнит-тестового таргета и линтера нет. Добавлять не будем, пока пользователь не попросит, и в CLAUDE.md это тоже отмечаем.
