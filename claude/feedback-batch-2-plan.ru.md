# План: доработки по Доработать.docx + доп. правки из чата (iOS + Android)

После одобрения план копируется в `claude/feedback-batch-2-plan.ru.md` (и в Android-репо) первым действием. Изменения UX сначала вносятся в `claude/ux-spec.ru.md` (и его копию в Android-репо), отличия для Android — в раздел «Android backlog».

## Контекст

Пользователь прислал `Доработать.docx` (8 пунктов + 9 скриншотов) и ещё 4 пункта в чате. Правки нужны в обоих репозиториях — `Green-Passport-IOS` и `GreenPasport` (Android) — это два порта одного приложения с общим Firebase-бэкендом (`chatroom-85fb8`) и общим `claude/ux-spec.ru.md`.

Код обоих проектов был изучен перед планированием, чтобы не чинить то, что уже работает. Там, где текст из docx разошёлся с реальным кодом, пользователь уточнил 3 спорных момента (Apple-вход, баланс очков, структура «Избранного»).

---

## 1. Вход через Apple — замокать (только iOS)

Email+пароль регистрация уже реализована на обоих платформах. Кнопка Sign in with Apple тоже есть в коде iOS (`AuthViewModel.swift:59-87`), но `Config/GreenPassport.entitlements` пуст — capability не добавлена (нужен платный Apple Developer Program). Пользователь подтвердил: пока замокать.

Не трогаем `ASAuthorizationController`-флоу и entitlements — перехватываем нажатие на уровне UI:

```swift
// AuthScreen.swift
private static let isAppleSignInAvailable = false // включить с Apple Developer Program

@ViewBuilder
private var appleButton: some View {
    if Self.isAppleSignInAvailable {
        SignInWithAppleButton(.continue, onRequest: viewModel.prepareAppleRequest, onCompletion: viewModel.completeAppleRequest)
            .signInWithAppleButtonStyle(.black)
    } else {
        Button {
            isAppleComingSoonPresented = true
        } label: {
            Label(String(localized: .continueWithApple), systemImage: "apple.logo")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .alert(String(localized: .appleSignInComingSoonMsg), isPresented: $isAppleComingSoonPresented) {}
    }
}
```

Новый ключ `apple_sign_in_coming_soon_msg` (ru/be/en) в `Localizable.xcstrings`. В `CLAUDE.md` → «Known limitations» — пункт про временно нерабочий Apple-вход.

**Android:** без изменений — Apple-вход там и не нужен и не показан (задокументировано в `ux-spec.ru.md`, раздел 7).

---

## 2. Иконки на Главной — размер и единый шрифт подписи

Баг iOS: у каждой подписи свой `.minimumScaleFactor(0.8)` (`HomeScreen.swift:77-96`), 5 слов сжимаются по-разному → визуально разный шрифт. Иконка занимает 38% плитки — многовато.

```swift
// HomeScreen.swift
private static let quickActionTileSize: CGFloat = 56
private static let quickActionSymbolScale: CGFloat = 0.28 // было 0.38

private var quickActions: some View {
    HStack(alignment: .top) {
        ForEach(HomeQuickAction.allCases, id: \.self) { action in
            Button {
                onQuickAction(action)
            } label: {
                VStack(spacing: Spacing.xSmall) {
                    SymbolTile(systemImage: action.systemImage, size: Self.quickActionTileSize, symbolScale: Self.quickActionSymbolScale)
                    Text(action.title)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
}
```

**Android:** шрифт там уже единый (используется `TextOverflow.Ellipsis`, не scale factor — бага нет), но для визуального паритета тоже уменьшаем `iconFraction` в `QuickActionButton.kt` с 0.38f до 0.28f.

`ux-spec.ru.md` раздел 6.4 (оба репо): «иконка ~38% плитки» → «~28%».

---

## 3. Шторка задания — «резиновая» высота

`TaskDetailSheet.swift:11` — жёсткий `.presentationDetents([.large])`, контент выровнен по верху → для короткого описания гигантское пустое поле перед кнопкой. На Android то же от обратного: `TaskDetailSheet.kt` форсирует `heightIn(min = 55% экрана)` + `Arrangement.SpaceBetween`.

**iOS** — меряем высоту контента, новый файл по правилу «один тип — один файл»:

```swift
// presentation/components/ContentHeightPreferenceKey.swift
import SwiftUI

struct ContentHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
```

`TaskDetailScreen.content(task:)` оборачивается в измерение высоты, `TaskDetailSheet.swift` подставляет `.presentationDetents([.height(max(measuredHeight, Self.minHeight))])` вместо `.large` (минимум 320pt). Шторка события (`eventDetailSheet`) не трогаем — там контента стабильно много.

`CLAUDE.md` → «Navigation»: уточнить, что шторка задания теперь контент-зависимой высоты.

**Android** — убрать принудительный `minHeight`/`SpaceBetween`, обычный layout по контенту в `TaskDetailSheet.kt`.

---

## 4. Баланс очков: поднять награду за события с QR-чекином (контент)

«Велопоездка» (SELF, без подтверждения) = 20. «Субботник»-**задание** с фото (`yard_cleanup_gomel`, PHOTO) = 80, не 50. Цифра 50 со скриншота — это отдельный тип контента, **событие** «Autumn clean-up in Gomel» (`gomel_park_cleanup`), подтверждение — очный QR-чекин (`checkInEvent`). Правила «очки от типа подтверждения» в коде нет, только соглашение в контенте. При этом `claude/points-economy.ru.md` уже называет целевой ориентир для «трудно подделать» активностей (QR/фото/события) — **60–100** очков; текущие события (20–60) этому не соответствуют. Пользователь подтвердил: поднять награду у событий с QR-чекином.

**Правка `scripts/content/events.js`** (`rewardPoints`, линейно +40, чтобы попасть в документированный диапазон 60–100):

| id | событие | было | стало |
|---|---|---|---|
| `gorky_park_cleanup` | Эко-субботник в парке Горького | 50 | **90** |
| `conscious_consumption_talk` | Лекция «Осознанное потребление» | 20 | **60** |
| `recycling_day_loshitsa` | День вторсырья | 30 | **70** |
| `clean_air_bike_ride` | Велопробег за чистый воздух | 40 | **80** |
| `gomel_park_cleanup` | Осенний субботник в Гомеле | 50 | **90** |
| `grodno_tree_planting` | Посадка деревьев в Гродно | 60 | **100** |
| `brest_swap_party` | Своп-вечеринка | 30 | **70** |
| `vitebsk_battery_drive` | Акция «Сдай батарейку» | 30 | **70** |
| `mogilev_energy_talk` | Лекция «Энергия дома» | 20 | **60** |
| `minsk_eco_fair` | Новогодняя эко-ярмарка | 30 | **70** |
| `christmas_tree_recycling` | Сдай ёлку на переработку | 40 | **80** |
| `pinsk_bird_feeders` | Мастер-класс: кормушки для птиц | 40 | **80** |

Это правит только шаблон контента в репозитории. Живые документы `events/{id}` в Firestore не меняются сами по себе — обновление через админ-панель или повторный `upsert`-прогон `scripts/seed-firestore.js` **на прод не запускается автоматически**, нужен отдельный явный запрос пользователя.

---

## 5. Кастомизация страницы купона

QR сейчас чёрно-белый без тюнинга, карточка — просто белый прямоугольник. У партнёров нет своего цвета/лого в модели — кастомизируем через фирменную палитру приложения (Forest), не партнёрскими цветами.

```swift
// CouponDetailScreen.swift
VStack(spacing: Spacing.medium) {
    QrCodeImage(payload: uiState.qrPayload ?? code)
        .frame(width: Self.qrSize, height: Self.qrSize)
        .padding(Self.qrPadding)
        .background(.white, in: .rect(cornerRadius: CornerRadius.medium, style: .continuous))
    // код, подсказка — без изменений
}
.padding(Spacing.large)
.background {
    RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
        .fill(LinearGradient(colors: [Palette.forest, Palette.forest.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
}
```

QR остаётся чёрно-белым на белой подложке (требование сканируемости). Android — аналогичный градиент вокруг `CouponCodeBlock` в `CouponDetailSheet.kt`.

---

## 6–7. Избранное: сердечко вместо закладки + вкладка «Места»

Иконка «сохранить» разная: задания/таб-бар — heart, советы/точки карты — bookmark. У магазинов/событий нет отдельной кнопки сохранения — сохраняются точки карты (`saved_map_point_ids`, локально), нигде кроме карты не видны. «Разнобой размеров маркеров» со скриншота — не баг (выбранная точка ×1.25), не трогаем.

**6a.** Везде `heart`/`heart.fill` вместо `bookmark`: `EcoTipsListScreen.swift:112`, `MapPointSheet.swift:46` (iOS); `EcoTipsListScreen.kt:205`, `MapScreen.kt:307` (Android).

**6b.** Третий сегмент «Места» в Избранном (один общий список, тип виден по иконке/цвету строки — выбор пользователя):

```swift
enum FavoritesSegment: Hashable, CaseIterable {
    case tasks, tips, places
    var title: LocalizedStringResource {
        switch self {
        case .tasks: return .tasks
        case .tips: return .tips
        case .places: return .places
        }
    }
}
```

`FavoritesUiState`/`FavoritesViewModel` переиспользуют существующие `ObserveMapPointsUseCase` + `SavedMapPointIdsUseCase` (то же, что питает карту — новой коллекции Firestore не нужно). `SavedMapPointIdsUseCase` — синхронное чтение UserDefaults, обновляем через `.onAppear` (не только `.task`), чтобы подхватывать изменения с вкладки «Карта». Строка — существующий `SymbolTile`+`point.type.title`, тап открывает `MapPointSheet`. Новый ключ `saved_places_empty`.

Android — третий сегмент в `FavoritesTabScreen.kt` (`SavedPlacesScreen.kt` по образцу `BookmarksScreen.kt`), данные через `ObserveSavedMapPointIdsUseCase`.

`ux-spec.ru.md` (оба репо): раздел 6.13 — `tasks/tips` → `tasks/tips/places`; раздел 6.12 — иконка сохранения сердце, точки видны в Избранном.

---

## 8. Календарь: цвет «есть события» + переход по тапу

Кружок «есть события» сейчас зелёный (`EventCountBadge.swift:14`), сливается с цветом выбора дня. Перехода-скролла к списку по тапу нет.

**8a.** Красный (`Palette.error`/`colorScheme.error` уже существуют, новый asset не нужен; выбор дня остаётся зелёным — два разных смысла):

```swift
// EventCountBadge.swift:14
label.backgroundColor = UIColor(Palette.error) // было Palette.forest
```

Android — `MonthCalendar.kt` badge: `MaterialTheme.colorScheme.error` вместо `colorScheme.primary`.

**8b.** `ScrollViewReader` + `.id("dayTitle")` + `.onChange(of: selectedDay) { proxy.scrollTo(...) }` в `CalendarScreen.swift`. Android — `LazyListState.animateScrollToItem` из `onDaySelected`.

**Отложено:** «разные цвета по дням под разный контент» — нет чёткого критерия («желательно»/«как-то» у пользователя), не реализуем наугад.

---

## 9. Игра «Эко-забег» — листья из бочек

`games/eco_runner/main.js` — независимые таймеры `spawnObstacle()`/`spawnLeaves()`, бочка (`🛢️`) — один из 4 равнозначных глифов `OBSTACLES`, без связи с листьями.

```js
const BARREL_GLYPH = '🛢️';
const BARREL_LEAF_CHANCE = 0.5;

function spawnObstacle() {
  const glyph = Engine.randomItem(OBSTACLES);
  obstacles.push({ x: stage.width + OBSTACLE_SIZE, glyph, wobble: 0 });
  if (glyph === BARREL_GLYPH && Math.random() < BARREL_LEAF_CHANCE) {
    spawnLeaves(stage.width + OBSTACLE_SIZE);
  }
}

function spawnLeaves(originX = stage.width + LEAF_SIZE) {
  // существующая логика, originX вместо жёсткого stage.width
}
```

Фоновый спавн листьев не убираем — это бонус. Общий код игры (Android-репозиторий, Firebase Hosting) — правка одна на оба приложения.

---

## 10. Баг: тумблер уведомлений не учитывает разрешение ОС

iOS: `ProfileViewModel.toggleNotifications` оптимистично включает тумблер до ответа системы; при открытии экрана статус не сверяется с `UNUserNotificationCenter`. Android: `onNotificationsToggle` вообще не проверяет разрешение, `hasNotificationPermission()` существует, но не используется; `POST_NOTIFICATIONS` не запрашивается.

**iOS:**
```swift
protocol NotificationPermission {
    func requestIfNeeded() async -> Bool
    func isAuthorized() async -> Bool
}
```
```swift
func toggleNotifications(_ isEnabled: Bool) {
    Task {
        uiState.notificationsEnabled = await setNotificationsEnabled.execute(isEnabled: isEnabled)
    }
}

func observe() async {
    uiState.notificationsEnabled = await notificationPermission.isAuthorized() && isNotificationsEnabled.execute()
    for await session in observeSession.execute() { /* без изменений */ }
}
```

**Android:**
```kotlin
fun onNotificationsToggle(enabled: Boolean) {
    viewModelScope.launch {
        val actuallyEnabled = enabled && notificationsRepository.hasNotificationPermission()
        runCatching { setNotificationsEnabled(actuallyEnabled) }.onFailure { ... }
        if (enabled && !actuallyEnabled) {
            // сигнал экрану: POST_NOTIFICATIONS launcher либо переход в настройки приложения
        }
    }
}
```
`ProfileScreen.kt` — `rememberLauncherForActivityResult(RequestPermission())` на Android 13+; при перманентном отказе — `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`.

---

## 11. Тёмная иконка при тёмной теме — iOS; Android откладываем

`AppIcon.appiconset` уже содержит `luminosity: dark` вариант (`icon2.png`), но это системный механизм (следует системной теме, не внутриигровой `app_theme`). `setAlternateIconName` не используется.

```swift
private func applyAppIcon(for theme: AppTheme) {
    let wantsDark = theme == .dark || (theme == .system && UITraitCollection.current.userInterfaceStyle == .dark)
    let desiredName = wantsDark ? "AppIconDark" : nil
    guard UIApplication.shared.alternateIconName != desiredName else { return }
    UIApplication.shared.setAlternateIconName(desiredName)
}
```
Вызывается из `ProfileViewModel.selectTheme` и из реакции на смену системной темы (при `app_theme == .system`). `Config/Info.plist` получает `CFBundleIcons`/`CFBundleAlternateIcons` с именем `AppIconDark`, использующим уже существующий `icon2.png`.

**Android — не делаем сейчас:** нет инфраструктуры (`<activity-alias>`), высокая цена (новый ресурс на каждый вариант + `PackageManager.setComponentEnabledSetting`, риск мигания иконки на части OEM-лаунчеров) при низкой отдаче. Пункт в «Android backlog» `ux-spec.ru.md`.

---

## Сознательно не делаем
- Прогон seed-скрипта на прод (п. 4) — только правка шаблона, прогон на прод по отдельному запросу.
- Разные цвета по дням под разный контент (п. 8) — нет критерия.
- Dark-иконка на Android (п. 11) — Android backlog.

---

## Верификация

**iOS:** `xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build`, затем вручную на симуляторе: Apple-кнопка показывает «скоро»; подписи на Главной одного размера; короткое задание — без пустого поля; купон — с градиентом; сохранение — сердце, вкладка «Места» в Избранном работает; календарь — красные дни + скролл по тапу; тумблер уведомлений корректно отражает системный статус; смена темы меняет иконку на «Домой».

**Android:** `./gradlew :app:assembleDebug`, аналогичные пункты (без Apple-кнопки, без смены иконки).

**Игра:** `games/eco_runner/index.html` — часть бочек спавнит листья рядом.

**Контент:** новые значения `rewardPoints` видны в `scripts/content/events.js`; прогон на прод — по отдельному запросу.
