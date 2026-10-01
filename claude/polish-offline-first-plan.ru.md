# План: полировка UX, жизни в играх, QR купонов, offline-first


## Контекст

Пользователь прогнал приложение и нашёл набор проблем:
- формулировка «Под честное слово» не нравится;
- игры: в «Поймай отходы» горизонтальный свайп уводит экран назад (на iOS 26 у `NavigationStack` полноширинный swipe-back, игра запушена в стек), игра уходит под плавающий таб-бар (`.ignoresSafeArea(edges: .bottom)` + таб-бар не скрыт);
- в играх можно ничего не делать и получать очки (в `waste_catcher` корзина в центре сама ловит ~35% предметов, счёт клампится в 0 после каждого события; `waste_sorting` — спам одной кнопкой без штрафа);
- плашка стрика на главной переносится на 2 строки;
- фильтры заданий — стена капсул без иерархии;
- у купонов нет механики погашения по QR;
- мигание «пусто» между загрузкой и данными, слишком крупный спиннер;
- задания перезагружаются после закрытия шторки — нужен offline-first для чтения и online-first для начисления очков.

Плюс проверка прошлых планов (`ios-port-plan`, `rewards-games-coupons-plan`, `points-economy`): почти всё сделано, хвосты — в шаге 9.

Решения пользователя: «Без подтверждения»; QR купона = ссылка, гасится любой камерой; 3 жизни, ошибка = −1; offline-first для всех списков и баланса.

---

## 0. Спека (`claude/ux-spec.ru.md`, копия в Android-репо)

Почему: правило репо — UX-изменения сначала в спеку. Обновить разделы: тип подтверждения SELF («Без подтверждения»), игры (полноэкранно, без таб-бара, 3 жизни), купоны (QR-ссылка, гашение партнёром, живой статус), фильтры заданий (форма со списками), состояния загрузки (данные из кеша сразу, спиннер только при пустом кеше, компактный спиннер), начисление очков только после ответа сервера.
В «Android backlog» добавить: ключ `no_proof_needed`, QR-ссылка купона + живой статус, offline-first слушатели вместо one-shot чтений, форма фильтров.

## 1. «Под честное слово» → «Без подтверждения»

Почему: формулировка звучит как недоверие. Ключ по правилу «ключ = английский текст»: `honor_system` удаляется, добавляется `no_proof_needed` (ru «Без подтверждения», be «Без пацвярджэння», en «No proof needed»).

```swift
case .selfReported:
    return .noProofNeeded
```
Файл: `presentation/tasks/states/TaskVerification+Texts.swift`, `Resources/Localizable.xcstrings`.

## 2. Игры: полноэкранно, без свайпа назад и таб-бара

Почему: игра запушена в стек вкладки → swipe-back перехватывает горизонтальные жесты, таб-бар висит поверх поля. `fullScreenCover` убирает обе проблемы сразу и логичен для игры (фокус-режим).

- `AppDestination.game` и ветка в `AppDestinationView` удаляются; `GamesHubRoute` хранит `@State private var playingGame: Game?` и показывает:
```swift
.fullScreenCover(item: $playingGame) { game in
    NavigationStack {
        GameWebRoute(game: game, container: container)
    }
}
```
- `GameWebScreen`: убрать `.ignoresSafeArea(edges: .bottom)`, добавить кнопку закрытия:
```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button(role: .close, action: onClose)
    }
}
```
  `onClose` и bridge `.close` вызывают `dismiss()` в `GameWebRoute` (уже есть для `.close`).
- `GameWebView.makeUIView`: страница-игра не должна скроллиться/зумиться нативно:
```swift
webView.scrollView.isScrollEnabled = false
webView.scrollView.pinchGestureRecognizer?.isEnabled = false
```
- Web (Android-репо `games/`): в `common/theme.css` `body { touch-action: none; }` (кнопки остаются кликабельными), в `waste_catcher` и `myth_or_fact` `event.preventDefault()` в `pointermove`/`pointerdown` — защита для Android WebView тоже.
- Проверить остальные 7 игр на simulator: поле целиком над home indicator, ничего не уезжает.

## 3. Жизни в играх (Android-репо `games/`, деплой `firebase deploy --only hosting`)

Почему: сейчас бездействие или спам дают очки. Жизни делают ошибку дорогой и быстро заканчивают «пустую» игру.

`common/game.js` — общий помощник + HUD сердечек (стили в `common/theme.css`):
```js
function lives(container, count, onGameOver) {
  let left = count;
  const hearts = Array.from({ length: count }, () => element('span', 'heart', '❤'));
  hearts.forEach((heart) => container.append(heart));
  return {
    lose() {
      if (left === 0) return;
      left -= 1;
      hearts[left].classList.add('lost');
      vibrate();
      if (left === 0) onGameOver();
    },
    get left() { return left; },
  };
}
const MAX_LIVES = 3;
```
Применение (`MAX_LIVES = 3`, `0` жизней → `GP.finish(score)` + `showResult`):
| Игра | −1 жизнь |
|---|---|
| waste_catcher | пойман не тот отход **или** нужный упал мимо; убрать клампинг-подушку (счёт не уходит ниже 0, но жизнь теряется) |
| waste_sorting | неверный бак; + таймаут на предмет (5 с без ответа = −1) |
| eco_quiz | неверный ответ |
| myth_or_fact | неверный ответ |
| water_saver | кран, протекавший дольше лимита (бак остаётся как общий таймер) |

Без жизней (бездействие уже даёт 0, награда только за завершение): eco_puzzle, eco_maze, eco_words — зафиксировать в спеке.
Сервер (`recordGameResult`) не трогаем: `score 0` → без награды, лимит 5/день и потолок 30 уже есть.

## 4. Плашка стрика на главной

Почему: в `ProgressHeroCard` уровень и плашка стоят в одном `HStack` в колонке шириной ~150 pt (справа маскот + пузырь 132 pt), текст плашки переносится.
```swift
ViewThatFits(in: .horizontal) {
    HStack(spacing: Spacing.xSmall) {
        levelCaption
        streakBadge
    }
    VStack(alignment: .leading, spacing: Spacing.xxSmall) {
        levelCaption
        streakBadge
    }
}
```
`streakBadge` и `levelCaption` получают `.lineLimit(1)` + `.fixedSize()`. Проверить в превью с `streakDays: 125` и крупным Dynamic Type.

## 5. Фильтры заданий: форма со списками вместо стены капсул

Почему: четыре секции одинаковых капсул на одинаковом фоне читаются как сплошной текст; непонятно, где одиночный, а где множественный выбор. Нативный `Form` с явными строками решает это.

`TaskFiltersSheet` переписывается на `Form`:
- **Статус** — одиночный выбор: `Picker` `.pickerStyle(.inline)` (строки с галочкой).
- **Подтверждение** — множественный: строка = `SymbolTile` (иконка типа) + название + подсказка (`hint`) + галочка.
- **Город** — `Picker` `.menu` в одной строке («Город — Минск»).
- **Категория** — множественный: строка с иконкой + галочка; добавить `TaskCategory.systemImage` (`arrow.3.trianglepath`, `leaf`, `bicycle`, `bag`, `book`).
- Нижняя кнопка «Показать N заданий» и «Сбросить» остаются.
```swift
private func checkRow(
    title: LocalizedStringResource,
    subtitle: LocalizedStringResource?,
    systemImage: String,
    isOn: Bool,
    action: @escaping () -> Void
) -> some View {
    return Button(action: action) {
        HStack(spacing: Spacing.small) {
            SymbolTile(systemImage: systemImage, style: .accent)
            VStack(alignment: .leading, spacing: Spacing.hairline) {
                Text(title)
                if let subtitle {
                    Text(subtitle).font(.footnote).foregroundStyle(Palette.secondaryText)
                }
            }
            Spacer()
            if isOn {
                Image(systemName: "checkmark").foregroundStyle(Palette.forest)
            }
        }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isOn ? .isSelected : [])
}
```
Кнопка фильтра в тулбаре получает бейдж-счётчик `activeCount` (было в плане Stage A, не сделано). Активные чипы над списком остаются.

## 6. Купоны: QR = ссылка, гасится сканом

Почему: сейчас QR кодирует голый код, погасить можно только своей кнопкой. Мок-партнёр: любой телефон сканирует QR → открывается ссылка → сервер гасит купон → у владельца купон сразу становится «Использован».

**Сервер (Android-репо `functions/src/shop.ts`)** — HTTP-функция `scanCoupon` (`onRequest`, `REGION`), в транзакции:
- нет купона / `code` не совпадает → страница «Купон не найден» (404);
- `status === 'USED'` → «Купон уже использован»;
- `expiresAtEpochMillis < now` → `status: 'EXPIRED'`, страница «Срок купона истёк»;
- иначе `status: 'USED', usedAtEpochMillis: now`, страница «Купон погашен» + название награды.
Код (8 символов) служит секретом — без него по одному `couponId` не погасить. Страница — минимальный HTML ru/en по `Accept-Language`. `firebase.json` hosting rewrite: `{"source": "/coupon", "function": {"functionId": "scanCoupon", "region": "europe-central2"}}`. Интеграционный тест рядом с тестом `markCouponUsed`.

**iOS:**
- build setting `COUPON_SCAN_URL = https://chatroom-85fb8.web.app/coupon` → `Config/Info.plist` `CouponScanURL`; `CouponQrPayloadUseCase` собирает `?id=<couponId>&code=<code>` (`URLComponents`).
- `Coupon` получает `isExpiredByServer` из `status == "EXPIRED"`; `status(at:)` учитывает его.
- `ShopRepository.observeCoupon(id:)` (слушатель документа) — `CouponDetailViewModel.observe()` подписывается, после скана экран сам переключается на «Использован» с `.sensoryFeedback(.success)`.
- Подсказка под QR: новый ключ `partner_scans_qr_msg` («Партнёр сканирует QR-код камерой — купон погасится автоматически»). Кнопка «Отметить использованным» остаётся как запасной путь (паритет с Android).
- Для демонстрации в `scripts/` Android-репо ничего не нужно: QR генерируется на лету.

## 7. Offline-first чтение, online-first начисление

Почему: сейчас все каталоги и баланс — one-shot `getDocuments()`, каждый вход/закрытие шторки — сетевой запрос и перерисовка. В Firestore iOS уже включён дисковый кеш; слушатель отдаёт кешированные данные мгновенно, потом сам догружает сервер и держит экран в актуальном состоянии.

**Data:** `fetch…` → `observe…` (через `FirestoreStream`) для: задания, выполненные id (`taskProgress`), события + регистрации/посещения, награды магазина, покупки (купоны), точки карты, игры, советы + прочитанные, история. Баланс: один слушатель документа пользователя вместо трёх `getDocument()`:
```swift
func observeWallet(userId: String) -> AsyncThrowingStream<Wallet, Error> {
    let document = FirestoreCollections.users(firestore).document(userId)
    return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
        return Wallet(
            availablePoints: snapshot.int(Self.fieldAvailablePoints) ?? 0,
            lifetimeXp: snapshot.int(Self.fieldLifetimeXp) ?? 0,
            streak: Self.streak(from: snapshot)
        )
    }
}
```
`Wallet` — новая модель в `domain/models`; use cases `Fetch*` → `Observe*` (переименование по слою).

**Пустой холодный кеш** (причина мигания «пусто»): `FirestoreStream.snapshots(of: Query)` пропускает пустой снапшот из кеша и ждёт серверный; если сервер молчит дольше `emptyCacheGracePeriod` (офлайн при первом запуске) — отдаёт пустой, чтобы не крутить спиннер вечно:
```swift
static func snapshots(of query: Query) -> AsyncThrowingStream<QuerySnapshot, Error> {
    return AsyncThrowingStream { continuation in
        let fallback = LatestTask()
        let registration = query.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
            if let error {
                continuation.finish(throwing: error)
                return
            }
            guard let snapshot else {
                return
            }
            if snapshot.metadata.isFromCache && snapshot.isEmpty {
                fallback.run {
                    try? await Task.sleep(for: emptyCacheGracePeriod)
                    continuation.yield(snapshot)
                }
                return
            }
            fallback.cancel()
            continuation.yield(snapshot)
        }
        continuation.onTermination = { _ in
            fallback.cancel()
            registration.remove()
        }
    }
}
```
(`includeMetadataChanges` нужен, чтобы получить событие «тот же пустой, но уже с сервера».)

**ViewModels:** `TasksListViewModel`, `HomeViewModel`, `TaskDetailViewModel` (`observeTask(id:)` вместо выборки всех заданий), `CalendarViewModel`, `ShopViewModel`, `CouponsViewModel`, `MapViewModel`, `GamesHubViewModel`, `EcoTipsListViewModel`, `HistoryViewModel` объединяют потоки в `observe()` через `withTaskGroup`, `isLoading` гаснет при первом значении основного потока. Удаляются: `onDismiss { refresh() }` в `TasksListRoute`/`HomeRoute`, рефреш по `scenePhase`, `.refreshable` на экранах со слушателями (данные живые).

**Начисление — только сервер:** callables уже серверные, оптимистичных обновлений нет — сохраняем. Баланс на главной меняется только из слушателя документа пользователя, т.е. после коммита транзакции на сервере. Исправить `SubmitGameResultUseCase`: сейчас `try?` глотает ошибку `recordGameResult`; ошибка пробрасывается, `GameWebScreen` показывает баннер `RewardFailure.network` («Нужен интернет, чтобы получить очки»). Локальный рекорд (SwiftData) пишется независимо — это не очки.

## 8. Состояния загрузки

- `StateView` `.loading`: `ProgressView()` обычного размера (без `.controlSize(.large)`), то же в `GameWebScreen`.
- Мигание пустого состояния, кроме шага 7: `HistoryViewModel`/`AchievementsViewModel` (nil-сессия → `.success([])` до первой реальной сессии), `CouponsViewModel` (nil userId), `FavoritesViewModel`, `ModerationViewModel` (гасит загрузку по флагу модератора, пока списки ещё `[]`), `ForumViewModel`/`GroupsViewModel`, `NotificationsViewModel` (стартует с `[]` без флага загрузки). Правило: `isLoading` снимается только когда пришло первое значение **того потока, который рисует список**; пустое состояние показывается только при `!isLoading`.

## 9. Хвосты прошлых планов

- Бонус стрика после чтения совета: `EcoTipDetailViewModel` берёт `streakBonus` из `RewardResult` и показывает как на остальных экранах.
- Счётчик активных фильтров на кнопке (шаг 5).
- Удалить ~60 неиспользуемых ключей (`quiz_*`, `sorting_*`, `puzzle_*`, `maze_*`, `game_*_title`, `game_play_again`, `shop_history_title`, `shop_empty_purchases`, `home_tile_*` кроме используемых, `for_you`, …) — перед удалением grep по символу; дописать be/en для `*_language_name`.
- `CLAUDE.md`: entitlement Sign in with Apple сейчас пустой (удалён в `eb11fbf`) — **не восстанавливаю молча**: если команда разработчика платная — вернуть `com.apple.developer.applesignin`, иначе поправить строку в CLAUDE.md. Добавить `google_logo` в список imagesets.
- Не делаем: UI-тест-таргет со скриншотами (Stage E) — отдельная задача; `profileBonus` в журнале уведомлений — бонус начисляет триггер, клиент его не видит.

---

## Проверка

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
cd ~/Personal/greenpassport-android/functions && npm test
firebase deploy --only hosting,functions:scanCoupon
```
Сценарии на симуляторе (`xcrun simctl install/launch`, скриншоты):
1. Задание SELF: в шторке и фильтрах «Без подтверждения» (ru/be/en).
2. Игры → «Поймай отходы»: игра на весь экран без таб-бара, водить корзину влево-вправо — экран не закрывается; поле не под home indicator; ✕ закрывает. Повторить для «Миф или факт» (свайпы) и остальных.
3. Жизни: в «Поймай отходы» ничего не делать — 3 упавших нужных отхода → конец игры, награда 0; в «Сортировке» спамить один бак — конец после 3 ошибок.
4. Главная со стриком 125 дней и Dynamic Type XL — плашка в одну строку (переносится целиком под уровень).
5. Фильтры: видно, где одиночный/множественный выбор; счётчик на кнопке; «Показать N».
6. Купон: открыть QR, отсканировать камерой другого телефона (или открыть URL в Safari) → страница «Купон погашен», в приложении купон сразу «Использован». Повторный скан → «уже использован». Купон с истёкшим сроком → «срок истёк».
7. Offline-first: открыть задания, закрыть шторку задания — без спиннера и перерисовки; выйти/войти в «Задания» — данные мгновенно. Включить авиарежим, перезапустить — списки из кеша. Выполнить задание офлайн → ошибка «нужен интернет», баланс не изменился; онлайн → баланс обновляется сам после ответа сервера.
8. Ни на одном экране нет вспышки пустого состояния между спиннером и данными; спиннер компактный.
9. Светлая и тёмная тема для изменённых экранов.

---

## Отступления при реализации

- `Coupon.isExpiredByServer` не добавлен: истечение и так считается по `expiresAtEpochMillis`, а статус `EXPIRED`, который пишет `scanCoupon`, нужен только серверу и другим клиентам.
- QR-ссылку собирает `ShopRepository.scanUrl(for:)` (чтение `Info.plist` — слой data), `CouponQrPayloadUseCase` только делегирует.
- История и достижения остались разовыми чтениями, но через `firstValue()` у слушателей — сначала кеш, затем сервер.
- `FetchPendingTasksUseCase` стал чистым `RankPendingTasksUseCase`: главная сама слушает задания и выполненные id и ранжирует их при каждом изменении.
- Повтор после ошибки: `retry()` перезапускает подписку (`LatestTask`) или увеличивает `observationId`, на который завязан `.task(id:)`.
- Подсказка `show_code_to_partner_msg` заменена на `partner_scans_qr_msg`; вместе с ней удалены ~70 неиспользуемых ключей от нативных игр и старых экранов.
- Симулятора `iPhone 17 Simulator` в системе нет (ни одного устройства), поэтому сборка проверялась через `-destination 'generic/platform=iOS Simulator'`.

