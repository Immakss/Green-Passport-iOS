# План: группы на iOS и бэкенде, затем перенос дизайна и логики iOS в Android

## Context
Пользователь просит три вещи:
1. Сначала реализовать уже написанный план групп и чата (`claude/community-groups-plan.ru.md`) на iOS и бэкенде. Android-экран групп остаётся на потом.
2. Перенести в Android дизайн iOS. Жидкое стекло, анимации, symbol effects и хаптику не переносить. Исключение — «стекло» верхней панели через библиотеку **Haze**: заголовок закреплён, контент уезжает под него, фон под заголовком размывается.
3. Починить карту на Android (фокус на геолокации, иначе на городе из анкеты, иначе на Минске) и перенести весь Android backlog из спеки §8.

Состояние Android по исследованию:
- Из ~28 пунктов backlog не сделан ни один. Частично сделаны три: offline-first, цвета, карта без ключа.
- Последние коммиты затрагивали только `functions/`, `games/` и спеку.
- Карта на Yandex MapKit центрируется по средней точке меток. Разрешений на геолокацию и кода локации нет. `SupportedCities` — только список имён.
- `FeatureScaffold` + `ScreenHeader`: заголовок уезжает при скролле (`exitUntilCollapsed`). Haze не подключён.

Решения пользователя:
- группы: сначала iOS и бэкенд, Android потом;
- backlog: весь, по фазам, отдельный коммит на фазу;
- Haze: на всех экранах с заголовком (`FeatureScaffold`). Главная и карта остаются со своими шапками. Нижний бар без стекла.

## Порядок и документы
Первым действием после одобрения сохраняются планы (по правилам обоих репозиториев):
- **iOS-репо**:
  - обновить `claude/community-groups-plan.ru.md`: убрать раздел про ENOSPC и добавить фазу 0.4 ниже;
  - сохранить этот общий план как `claude/android-parity-plan.ru.md`.
- **Android-репо**: `claude/ios-parity-plan.ru.md`. Это подробный план фаз A1–A10, по правилам Android CLAUDE.md: «почему» и Kotlin-код на каждый шаг, проверка в конце.

Порядок работы:
- Перед кодом каждой фазы правится спека в обоих репо: сначала отмечаются пункты backlog, затем дописываются новые решения. Файлы спеки идентичны, правки синхронные.
- Коммит на каждую фазу в своём репо, по шаблону коммитов из CLAUDE.md, без упоминания ИИ.
- `firebase deploy` и запуск `backfill-groups.js` — только после явного подтверждения пользователя.

---

## Фаза 0 — группы и чат (iOS + бэкенд)
Делается строго по `claude/community-groups-plan.ru.md`, разделы 1–6:
- Форум: диагностика причины, показ `message_not_sent_msg` под полем ввода.
- Данные `groups`: добавить `ownerId`, `createdAtEpochMillis`, `inviteCode`.
- Сообщения: `chats/{groupId}/messages`.
- Правила (`isJoining`/`isLeaving`/`isGroupMember`) и тесты в `rules-tests/rules.test.js`.
- `scripts/backfill-groups.js` по образцу `seed-firestore.js`.
- iOS:
  - модели `GroupMessage` и `GroupMember`;
  - методы `CommunityRepository`, use cases;
  - `GroupDetailRoute`/`Screen`/`ViewModel`/`UiState`, `AppDestination.group(id:)`;
  - общий `MessageComposer`, вынесенный из `ForumScreen`;
  - «Вступить по коду», `ShareLink`, выход из группы, новые строки ru/be/en.

**0.4 (добавка к плану). Новые правила ломают создание групп на Android.**
- Почему: `allow create` начинает требовать `ownerId` и `inviteCode`, а Android `FirestoreCommunityRepository.createGroup` пишет только `name` и `memberIds`. После деплоя правил создание группы на Android упадёт с `PERMISSION_DENIED`.
- Решение: в той же фазе минимально поправить Android, не трогая UI:
  - `createGroup` пишет `ownerId`, `createdAtEpochMillis` и `inviteCode`;
  - генератор кода — порт `functions/src/couponCode.ts` в `core`;
  - мёртвый код чата переименовать с `sentAtEpochMillis` на `createdAtEpochMillis`, как в плане.
```kotlin
object InviteCodeGenerator {
    private const val ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
    private const val LENGTH = 6

    fun generate(): String {
        val random = SecureRandom()
        return (1..LENGTH).map { ALPHABET[random.nextInt(ALPHABET.length)] }.joinToString("")
    }
}
```
Экран группы и чат на Android идут в backlog спеки, как и записано в плане.

**0.5. Баг цвета на iOS.** В `MintSurfaceHigh.colorset` тёмный вариант раскладывается в `#323A44`, синевато-серый. На Android этот токен `#32443A`, то есть на iOS перепутаны каналы g/b. Исправить colorset на `#32443A`.

---

## Фазы Android (репо `~/Personal/greenpassport-android`)

### A1. Токены и компоненты дизайн-системы
Почему: экраны iOS построены на нейтральных сгруппированных фонах, белых карточках с радиусом 22, плитках-скруглённых квадратах и секциях-списках. На Android сейчас мятные карточки (`surfaceContainer`) и круглые `IconCircle`.

Токены:
- `Color.kt`:
  - фон экрана и карточек — по пункту спеки «Цветовая схема»: нейтральные фоны вместо мятной заливки;
  - `surfaceContainer` становится цветом карточки (светлая тема — белый, тёмная — `#1E2A24`);
  - `MintSurfaceHigh` — фон плиток;
  - если в спеке нет точных значений фона экрана, сначала дописать их в спеку.
- `Dimens.kt` по шкале iOS `Spacing`: 2 / 4 / 8 / 12 / 16 / 24 / 32, горизонталь экрана 20.
- `Shape.kt`: карточка 22, поле 14, малый 10.

Компоненты в `core/designsystem/component` (по одному на файл):
- `SymbolTile` вместо `IconCircle`. Скругление — `size * 0.28`, иконка — `size * 0.5`. Стили `SymbolTileStyle.Accent | Prominent | Muted | Tinted(color)`:
  - Accent: фон `MintSurfaceHigh`, иконка `Forest`;
  - Prominent: фон `Forest`, иконка белая;
  - Muted: фон `fieldBackground`, иконка вторичного цвета.
- `ListSection`: аналог insetGrouped — белый скруглённый блок со строками и разделителями. `GpListRow`: min 56, title body / subtitle footnote.
- Обновить `ProgressHeroCard`:
  - капсула серии;
  - пузырь «N XP до уровня»;
  - маскот 96;
  - прогресс 8 dp, Lime на `onForest` 0.22.
- Обновить `PointsChip`: капсула Lime, «⚡ +N».
- `ChoiceCapsule` (замена `GpFilterChip`), `StepIndicator`, `StateView` (маскот 120 + текст / «Повторить»).
- `HeroImageCard`: градиент до 0.55, текст слева, отступ снизу 24.
- Кнопка `GpPrimaryButton` — залитая капсула `Forest` высотой 50.
```kotlin
@Composable
fun SymbolTile(icon: ImageVector, style: SymbolTileStyle, modifier: Modifier = Modifier, size: Dp = Dimens.TileSizeDefault) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .size(size)
            .clip(RoundedCornerShape(size * CORNER_FRACTION))
            .background(style.background()),
    ) {
        Icon(icon, contentDescription = null, tint = style.iconColor(), modifier = Modifier.size(size * ICON_FRACTION))
    }
}
```
Иконки — Material Symbols, ближайшие к SF Symbols из iOS.

### A2. Стеклянная верхняя панель (Haze)
Почему: пользователь хочет закреплённый заголовок. Контент уходит под него, фон под заголовком размывается, как на iOS. Сейчас `ScreenHeader` просто уезжает вместе со скроллом.
- `libs.versions.toml`: `haze` и `haze-materials` (`dev.chrisbanes.haze`, последняя стабильная), подключить в `:core` и `:app`.
- Новый `FeatureScaffold`:
  - `Box`: контент рисуется на всю высоту с `hazeSource`, заголовок поверх него;
  - верхний отступ контента — высота заголовка;
  - стекло (`hazeEffect`) и hairline-разделитель включаются только когда контент уже под заголовком (`pinnedScrollBehavior().state.overlappedFraction > 0`);
  - в покое заголовок прозрачный, как scroll edge на iOS.
```kotlin
val hazeState = rememberHazeState()
val scrollBehavior = TopAppBarDefaults.pinnedScrollBehavior()
val isContentUnderHeader = scrollBehavior.state.overlappedFraction > 0f
Box(modifier.fillMaxSize().background(MaterialTheme.colorScheme.background).nestedScroll(scrollBehavior.nestedScrollConnection)) {
    Box(Modifier.fillMaxSize().hazeSource(hazeState)) {
        content(PaddingValues(top = headerHeight, bottom = bottomPadding))
    }
    ScreenHeader(
        title = title,
        onNavigateBack = onNavigateBack,
        modifier = Modifier
            .onSizeChanged { headerHeightPx = it.height }
            .then(if (isContentUnderHeader) Modifier.hazeEffect(hazeState, HazeMaterials.thin(MaterialTheme.colorScheme.background)) else Modifier),
    )
}
```
- `ScreenHeader` теряет `heightOffsetState`. Заголовок по центру, `titleMedium`, круглая кнопка «назад».
- Все экраны внутри `FeatureScaffold` передают `innerPadding` в `contentPadding` своих `LazyColumn` или `verticalScroll`, а не в `Modifier.padding`. Иначе контент не уйдёт под стекло. Проверка — обход всех экранов из `AppNavHost`.
- В Android CLAUDE.md поправить описание `FeatureScaffold`: заголовок закреплён, под ним стекло Haze.

### A3. Экраны по дизайну iOS
Почему: та же структура и тот же порядок секций, что на iOS. Анимации и стекло не переносятся.

Главная:
- шапка: дата, «Привет, Имя» без 👋, аватар 44 открывает профиль;
- карточка прогресса с серией;
- быстрые действия: 5 колонок, плитка 56, иконка ~38% плитки, все плитки одного стиля (одна палитра);
- ближайшее событие;
- «Твои задания» отдельными карточками с отступом 12.

Магазин:
- карточка баланса;
- каталог одной карточкой с разделителями;
- строка «Мои купоны» (сам экран — в A8).

Профиль: секции-списки, залитые цветные плитки 30 (`Tinted`, цвета из таблицы спеки 6.8), «Выйти» отдельной секцией.

Остальные экраны: задания, избранное, советы, календарь, сообщество, форум, группы, уведомления, достижения, история, вход, онбординг, анкета, обратная связь, модерация. Карточки или `ListSection` повторяют разметку iOS (полный перечень — в Android-плане A3).

Убрать `sectionColors` из плиток, сердец, звёзд и меток карты. Цвета разделов остаются только для корзин сортировки, аватаров и плиток профиля.

### A4. Offline-first
Почему: задания, события, магазин, метки карты, советы и баланс читаются разово через `.get().await()`. Поэтому при возврате на экран всё грузится заново, а пустой кеш показывает «пусто».
- `core/datasource/remote/FirestoreFlows.kt` — порт `FirestoreStream`:
  - `callbackFlow` с `MetadataChanges.INCLUDE`;
  - пустой или отсутствующий снапшот из кеша пропускается, пока не ответит сервер или не пройдут 5 с;
  - `awaitClose { registration.remove() }`.
- Репозитории получают `observe…()`. Баланс становится живым `Wallet` из документа пользователя. ViewModel собирают их через `stateIn(WhileSubscribed)` и не перезапрашивают.
```kotlin
fun Query.snapshotsFirstFromCache(): Flow<QuerySnapshot> = callbackFlow {
    var serverAnswered = false
    val registration = addSnapshotListener(MetadataChanges.INCLUDE) { snapshot, error ->
        if (error != null) { close(error); return@addSnapshotListener }
        if (snapshot == null) return@addSnapshotListener
        if (!snapshot.metadata.isFromCache) serverAnswered = true
        if (snapshot.isEmpty && snapshot.metadata.isFromCache && !serverAnswered) return@addSnapshotListener
        trySend(snapshot)
    }
    awaitClose { registration.remove() }
}
```
(Таймаут 5 с — через `launch { delay(CACHE_GRACE_MILLIS); … }` внутри `callbackFlow`, точный код — в Android-плане.)

### A5. Карта
Почему: сейчас камера стоит в средней точке меток, между 12 городами. Без меток она остаётся на дефолте MapKit, а фильтр до первой установки камеры центрирует её по подмножеству. К тому же `update` в `YandexMap` пересоздаёт все метки на каждой рекомпозиции.
- Манифест `:feature:map`: `ACCESS_COARSE_LOCATION` и `ACCESS_FINE_LOCATION`. Зависимость `play-services-location`.
- `core/model/map/GeoPoint.kt`, `MapFocus.kt` (`sealed interface`: `UserLocation`, `City`).
- `SupportedCities.centers` и `defaultCity` — те же координаты, что на iOS (`claude/map-focus-plan.ru.md` §3).
- `core/model/map/LocationRepository` + `core/datasource/local/FusedLocationRepository`:
  - `getCurrentLocation(Priority.PRIORITY_BALANCED_POWER_ACCURACY, token)` под `withTimeoutOrNull(5 s)`;
  - без разрешения возвращает `null`;
  - биндинг — в Hilt-модуле.
- `feature/map/domain/ResolveMapFocusUseCase`: геолокация → город из `observeProfile(uid).first()` → Минск.
```kotlin
class ResolveMapFocusUseCase @Inject constructor(
    private val locationRepository: LocationRepository,
    private val authRepository: AuthRepository,
    private val userProfileRepository: UserProfileRepository,
) {
    suspend operator fun invoke(): MapFocus {
        locationRepository.currentLocation()?.let { return MapFocus.UserLocation(it) }
        val city = profileCity() ?: SupportedCities.DEFAULT_CITY
        return MapFocus.City(SupportedCities.centers[city] ?: SupportedCities.defaultCenter)
    }
}
```
- `MapViewModel`:
  - `locationPermissionResolved: MutableStateFlow<Boolean>`;
  - фокус считается один раз: `locationPermissionResolved.filter { it }.take(1).map { resolveMapFocus() }`, вливается в `combine` состояния;
  - без `init {}` — по правилам репо.
- `MapScreen`:
  - при первом открытии `rememberLauncherForActivityResult(RequestMultiplePermissions())`;
  - если разрешение уже дано, запрос не показывается;
  - результат передаётся в `onLocationPermissionResolved()`.
- `YandexMap`:
  - камера ставится один раз по `focus`, на метки не реагирует;
  - метки пересоздаются только при смене `visiblePoints` (`remember(visiblePoints)`);
  - `UserLocationLayer` при разрешении и круглая кнопка «моё местоположение».
- Шторка точки: кнопка `build_route` открывает `geo:lat,lng?q=lat,lng(name)` в системных картах. «Сохранить» — рядом, две равные кнопки.
- Метки получают плитку `Prominent` вместо цветов разделов. Метки читаются живым слушателем из A4.
- **Позиция по пункту «карта работает без ключа»:** Yandex MapKit без ключа не работает. Предлагаю оставить список-фолбэк и записать это в спеку как осознанное отличие Android, а не тянуть вторую картографическую библиотеку.

### A6. Мелкие пункты backlog
- Тема «Системная / Светлая / Тёмная»: DataStore `app_theme`, `GreenPassportTheme(darkTheme = …)`, выпадающий список в профиле.
- Переключатель уведомлений реально работает: `AndroidRewardNotifier` и `EventReminderWorker` проверяют `notifications_enabled`.
- Строки:
  - `no_proof_needed` вместо `honor_system`;
  - `hello_name` и `hello` без 👋;
  - подзаголовок строки задания — категория, если нет статуса.
- Ссылки:
  - email и телефон поддержки — `mailto:` / `tel:`;
  - `mediaUrl` совета — `ACTION_VIEW`.
- Диалоги подтверждения: покупка награды, удаление поста в модерации.
- Шторка события показывает описание полностью.
- PHOTO-задания: выбор «Снять фото» (`TakePicture` + `FileProvider`) или «Из галереи».

### A7. Экономика очков
- Капсула серии в карточке прогресса.
- `streak_bonus_msg` после начислений, из ответов колбеков.
- Отметка на событии по QR (callable из `functions/`, сканер `play-services-code-scanner`, который уже подключён).
- `submitFeedback` и `submitSurveyAnswer` через колбеки вместо прямой записи. Имена колбеков — в `CloudFunctionNames`.

### A8. Веб-игры
- `FirestoreGamesRepository` (каталог `games`, живой).
- `GamesHubScreen` — карточки-строки.
- `GameWebScreen`:
  - `WebView`, URL `GAMES_BASE_URL + path + ?lang=&theme=`;
  - `addJavascriptInterface(GameBridge, "GreenPassportAndroid")` с `finish(score)` → `SubmitGameResultUseCase` (Room + `recordGameResult`) и `close()`.
- Маршрут на весь экран, без нижнего бара и без жеста «назад»: `BackHandler` поглощает жест, закрыть можно только кнопкой.
- `no_internet_for_points_msg` при ошибке колбека.
- Удалить нативные игры (Maze, Puzzle, Quiz, WasteSorting) и их маршруты. Пункт «Лабиринт: свайпы» снимается, потому что нативного лабиринта больше нет.

### A9. Купоны
- `Coupon`: добавить `code`, `expiresAtEpochMillis`, `status`. `CouponsScreen` с вкладками «Активные / Использованные / Истёкшие».
- Шторка купона:
  - QR со ссылкой `COUPON_SCAN_URL?id=&code=` (генерация через `com.google.zxing:core`);
  - код моноширинным шрифтом;
  - `partner_scans_qr_msg`;
  - «Отметить использованным» с подтверждением;
  - живой статус по документу покупки.
- Напоминание за сутки до конца срока (WorkManager, с учётом `notifications_enabled`).

### A10. Фильтры заданий и Sign in with Apple
- Фильтры:
  - кнопка фильтров с бейджем числа активных фильтров;
  - `ModalBottomSheet` со секциями «Статус», «Подтверждение», «Город», «Категория»: строки-галочки с плитками, «Сбросить», «Показать N заданий»;
  - ряд активных фильтров-капсул над списком.
- Apple:
  - `OAuthProvider.newBuilder("apple.com")` + `startActivityForSignInWithProvider`;
  - чёрная капсула на экране входа;
  - маппинг ошибок в `AuthFailure`.

---

## Что не переносится
- Liquid glass (кроме стекла заголовка через Haze).
- `.animation`, переходы, symbol effects, хаптика.
- Экран группы и чат на Android: в backlog, будет следующей задачей.

## Проверка
iOS (фаза 0):
```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
cd ~/Personal/greenpassport-android && firebase emulators:exec --only firestore,storage "npm --prefix rules-tests test"
```
Сценарии 1–6 из `community-groups-plan.ru.md`. Плюс: Android после деплоя правил по-прежнему создаёт группу.

Android (после каждой фазы):
```bash
./gradlew assembleDebug && ./gradlew build && ./gradlew detektAll
./gradlew installDebug
```
Ручные сценарии на эмуляторе:
1. **Haze.** На «Заданиях» в покое заголовок прозрачный. При скролле контент уходит под заголовок, видно размытие и разделитель. Проверить светлую и тёмную темы и экран с кнопкой «назад».
2. **Дизайн.** Главная, магазин, профиль и списки визуально совпадают со скриншотами iOS (`xcrun simctl io booted screenshot`) по структуре, отступам и плиткам.
3. **Карта:**
   - разрешить → камера на пользователе (эмулятор: Extended controls → Location), кнопка «моё местоположение» работает;
   - отказать → город из анкеты;
   - гость → Минск;
   - метки обновляются, камера не прыгает;
   - «Маршрут» открывает системные карты.
4. **Offline-first.** Авиарежим → списки показываются из кеша. Возврат на экран без повторной загрузки.
5. **Игры.** Открытие на весь экран, «назад» не закрывает. Финиш начисляет очки, в авиарежиме показывается `no_internet_for_points_msg`.
6. **Купоны.** Покупка с подтверждением → QR. Скан QR телефоном → статус «использован» без перезахода.
7. **Фильтры, тема, переключатель уведомлений, Apple sign-in, отметка на событии по QR, серия** — по сценариям спеки.
