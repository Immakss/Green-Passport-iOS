# Фильтры заданий, купоны со сроком, экономика очков, веб-игры и проверка отступов

## Контекст

iOS-порт готов (ветка `main`, репозиторий `Green-Passport-iOS`). Команда прислала следующий список задач:
1. фильтры в заданиях;
2. игры сделать через WebView и увеличить их количество;
3. продумать механику получения и траты очков;
4. экран купленных купонов со сроком действия;
5. проверить отступы в элементах.

Решения пользователя:
- **Фильтры:** по статусу, по способу подтверждения, по городу, плюс новый вид фильтров.
- **Игры:** HTML5 на Firebase Hosting, каталог в Firestore, 8 игр: 4 текущие переносим в веб и добавляем 4 новые.
- **Очки:**
  - за посещение события по QR;
  - ежедневная серия;
  - бонус за заполненный профиль;
  - за отзыв и опрос.
- **Купоны:** код, QR, срок действия, статус «Использован».

Бэкенд (`functions/`, `firestore.rules`, `scripts/seed-firestore.js`, `firebase.json`) лежит в Android-репозитории `~/Personal/greenpassport-android`. Поэтому серверная часть и сами веб-игры делаются там, коммиты там же. UI Android в эту задачу не входит: он уходит в «Android backlog» в `claude/ux-spec.ru.md`.

Как сейчас (факты из кода):
- `recordGameResult` принимает только 4 id игр, зашитых в `KNOWN_GAMES` (`functions/src/activities.ts`). Не больше `GAME_MAX_POINTS = 30` за игру и `GAME_REWARDS_PER_DAY = 5` в день.
- `redeemReward` (`functions/src/shop.ts`) создаёт покупку без кода, без срока и без статуса.
- У событий есть `rewardPoints`, но их никто не начисляет: запись на событие пишет сам клиент, посещение не проверяется.
- Причина `FEEDBACK_SUBMITTED` есть в enum, но не используется.

Первое действие после одобрения — сохранить этот план в `claude/rewards-games-coupons-plan.ru.md` в обоих репозиториях.

Все изменения сервера обратно совместимы с текущим Android-приложением:
- новые поля в ответах — дополнительные;
- старые id игр остаются в каталоге;
- прямые записи отзывов из Android по-прежнему разрешены правилами.

---

## Этап A. Фильтры заданий (iOS)

### Почему
Сейчас есть только ряд капсул «Для тебя / Все / 5 категорий». Выполненные задания смешаны с доступными. Нельзя найти задания, которые можно выполнить прямо сейчас (без фото и QR), и задания другого города.

### Что делаем
- **Кнопка фильтров:** вместо ряда капсул в тулбаре кнопка `line.3.horizontal.decrease.circle`, при активных фильтрах — `.fill` со счётчиком. Под заголовком — ряд активных фильтров-капсул с крестиком, чтобы снимать их по одному.
- **Шторка фильтров** (`.presentationDetents([.medium, .large])`), секции:
  - **Статус** (`Picker(.segmented)`): Доступные / На проверке / Выполненные / Все. По умолчанию «Доступные».
  - **Подтверждение** (множественный выбор капсулами): Сам / Фото / QR.
  - **Город:** «Мой город» (из анкеты) / любой из `SupportedCities` / Все города.
  - **Категория:** 5 категорий, множественный выбор.
  - **Кнопки:** «Сбросить» и «Показать N заданий».
- «Для тебя» остаётся сортировкой по умолчанию: сначала свой город, потом интересы.

```swift
struct TaskFilters: Hashable {
    var status: TaskStatusFilter = .available
    var verifications: Set<TaskVerification> = []
    var city: TaskCityFilter = .profileCity
    var categories: Set<TaskCategory> = []

    var activeCount: Int {
        let statusCount = status == .available ? 0 : 1
        let cityCount = city == .profileCity ? 0 : 1
        return statusCount + cityCount + verifications.count + categories.count
    }
}
```

Фильтрация — в `TasksListUiState.visibleTasks`. Она учитывает `completedTaskIds`, `pendingTaskIds`, `profile.city`. Файлы: `presentation/tasks/states/TaskFilters.swift`, `TaskStatusFilter.swift`, `TaskCityFilter.swift`, `presentation/tasks/ui/TaskFiltersSheet.swift`, правки `TasksListScreen` и `TasksListViewModel`. Старый `TaskFilter.swift` удаляется.

---

## Этап B. Купоны: код, QR, срок, «Использован»

### Почему
Купон сейчас — просто строка в истории. Показать его партнёру нечего, срока нет, отметить использованным нельзя.

### Сервер (Android-репо)
`shop.ts` → `redeemReward`:
- генерирует код из 8 символов (алфавит без путаницы: `ABCDEFGHJKMNPQRSTUVWXYZ23456789`);
- берёт `validityDays` из `shopItems/{id}` (по умолчанию `DEFAULT_COUPON_VALIDITY_DAYS = 30` в `config.ts`);
- пишет в покупку `code`, `expiresAtEpochMillis`, `status: "ACTIVE"`;
- возвращает те же поля плюс новые.

```ts
const expiresAtEpochMillis = redeemedAtEpochMillis + validityDays * DAY_MILLIS;
tx.create(couponRef, {
  userId: uid, rewardId, redeemedAtEpochMillis, pointsCost: cost,
  code: generateCouponCode(), expiresAtEpochMillis, status: 'ACTIVE',
});
return { couponId: couponRef.id, rewardId, redeemedAtEpochMillis, code, expiresAtEpochMillis };
```

Новый callable `markCouponUsed({ couponId })`:
- проверяет владельца, статус `ACTIVE` и что купон не истёк;
- ставит `status: "USED"` и `usedAtEpochMillis`.

`seed-firestore.js`: у каждого купона в каталоге появляется `validityDays` (14–60). Unit-тест на `generateCouponCode` (алфавит и длина).

### iOS
- **Модель:** `Coupon` получает `code: String?`, `status: CouponStatus` (`active`/`used`/`expired`), `expiresAt`, `usedAt`. Истёкшие вычисляются на клиенте: `expiresAt < now` и статус не `used`. У старых купонов без кода и срока пишем «Без срока действия», код не показываем.
- **Магазин:** секция «Мои покупки» заменена строкой «Мои купоны (N активных)» → экран `CouponsRoute` / `CouponsScreen`.
  - Сверху `Picker(.segmented)`: Активные / Использованные / Истёкшие.
  - Карточка купона: партнёр, название, «Действует до 12 ноября». Если до конца срока 3 дня и меньше — «Осталось 2 дня» цветом ошибки.
- **Шторка купона:**
  - крупный код (копируется долгим нажатием, `.textSelection`);
  - QR с кодом (CoreImage `CIFilter.qrCodeGenerator()`), яркость экрана не трогаем;
  - кнопка «Отметить использованным» с подтверждением → `markCouponUsed`.
- **После покупки** сразу открывается шторка нового купона.
- **Напоминание** за сутки до окончания срока — локальное уведомление `coupon_expiring_<id>`, пишется в журнал. На Android для этого уже есть `NotificationDeepLink.COUPON_EXPIRING`.
- **Пункт «Мои купоны» в профиле** — тот же экран.

---

## Этап C. Экономика очков

Правила сведены в `claude/points-economy.ru.md` в обоих репозиториях. Все числа — константы в `functions/src/config.ts`.

| Источник | Очки / XP | Ограничение | Как |
|---|---|---|---|
| Задание SELF / QR / PHOTO | из задания | SELF — не больше 3 в день (как сейчас) | существующие callables |
| Совет | из совета | один раз | `recordTipRead` |
| Игра | min(score, `maxPoints` игры) | не больше 5 в день | `recordGameResult` |
| **Посещение события** | `rewardPoints` события | один раз, окно от −2 ч до +6 ч от начала | новый `checkInEvent(code)`, QR `greenpassport:event:<eventId>:<secret>`, секреты в `eventSecrets` |
| **Ежедневная серия** | +5 за первую активность дня, +35 на каждый 7-й день подряд | раз в сутки (Europe/Minsk) | внутри `award()`: `users/{uid}.streak {count, lastDay}` |
| **Анкета заполнена** | +50 | один раз | триггер на `users/{uid}`: появилось `profileCompletedAt`, флаг `profileBonusAwarded` |
| **Отзыв** | +10 | не чаще раза в 7 дней | новый `submitFeedback` (фильтр мата на сервере, `wordFilter.ts`) |
| **Опрос** | +10 | один раз на опрос | новый `submitSurveyAnswer` |
| Трата: купон | −`pointsCost` | нужен баланс | `redeemReward` |

Серия в `award()`:

```ts
const streak = user.get('streak') ?? { count: 0, lastDay: null };
if (streak.lastDay !== today) {
  const count = streak.lastDay === yesterday ? streak.count + 1 : 1;
  const bonus = count % STREAK_WEEK_LENGTH === 0 ? STREAK_WEEK_BONUS : STREAK_DAILY_BONUS;
  tx.set(userRef, { streak: { count, lastDay: today } }, { merge: true });
  ledger(tx, uid, bonus, 'STREAK_BONUS');
}
```

- Ответ callables получает необязательное `streakBonus`. Клиент показывает «+5 за серию».
- `firestore.rules`: клиенту запрещено писать `streak` и `profileBonusAwarded` в `users` (как сейчас `availablePoints`/`lifetimeXp`); `eventSecrets` закрыт для чтения.
- `seed-firestore.js`: генерирует секреты событий и QR-картинки в `scripts/qr/`, как уже делается для заданий.

**iOS:**
- **Шторка события:** после записи и в окне события — кнопка «Отметиться на месте» → сканер QR (используем `QrScannerScreen`) → `checkInEvent`.
- **Главная:** рядом с уровнем в карточке прогресса счётчик серии (`flame.fill`, «5 дней подряд»).
- **Отзывы:** через новые callables (`FeedbackRepository` → `FirebaseFeedbackRepository` на Functions) и сообщение «+10 очков».
- **Уведомления:** `PointsEarnReason` расширяется (`eventAttended` уже есть, добавляются `streakBonus`, `profileBonus`, `feedbackSubmitted`) и выводится в журнал.

Тесты: unit на расчёт серии (граница суток, разрыв, 7-й день). Интеграционные — на `checkInEvent` и `markCouponUsed` в `functions/integration` с эмуляторами.

---

## Этап D. Веб-игры (8 штук)

### Почему
Игр 4, они нативные и написаны дважды: на Kotlin и на Swift. Веб-игры на Hosting пишутся один раз для обеих платформ, а новую игру можно добавить без релиза приложений.

### Каталог и сервер
Коллекция `apps/greenpassport/games/{gameId}`:

```ts
{ titles: { ru, be, en }, path: 'eco_quiz/index.html', sfSymbol: 'questionmark.bubble.fill',
  materialIcon: 'Quiz', maxPoints: 30, order: 4, isActive: true }
```

- **`recordGameResult`:** вместо `KNOWN_GAMES` читает `games/{gameId}` (существует и `isActive`); очки = `min(score, maxPoints)`. Старые 4 id остаются, поэтому текущий Android работает.
- **Правила:** `games` — чтение для вошедших, запись запрещена.

### Игры
Папка `games/` в Android-репо, `firebase.json` → `hosting.public = "games"`. Чистый HTML/CSS/JS без фреймворков.

Общие файлы:
- `common/bridge.js` — `GreenPassport.finish(score)` и `GreenPassport.close()`. Внутри определяется платформа: iOS — `webkit.messageHandlers.greenPassport`, Android — `window.GreenPassportAndroid`.
- `common/theme.css` — токены палитры (`--forest`, `--mint-surface-high`, `--lime`), светлая и тёмная тема по `?theme=`.
- `common/i18n.js` — тексты ru/be/en по `?lang=`.

Игры:
1. `eco_puzzle` — память, 6 пар (правила как сейчас).
2. `waste_sorting` — 30 с, 4 бака.
3. `eco_maze` — 5×5, свайпы и стрелки.
4. `eco_quiz` — 5 вопросов.
5. **`waste_catcher`** — «Поймай отходы»: 45 с, двигаешь бак нужного типа под падающие предметы.
6. **`myth_or_fact`** — «Правда или миф»: 10 утверждений, свайп влево или вправо.
7. **`eco_words`** — «Эко-слова»: поиск 6 слов в сетке 8×8.
8. **`water_saver`** — «Сбереги воду»: 30 с, закрывай капающие краны.

Правила очков в каждой игре — константы вверху файла. Игра всегда вызывает `GreenPassport.finish(score)`. Экран итога рисует сама игра, кнопка «Играть снова» перезапускает игру внутри WebView.

### iOS
- **Удаляем нативные игры:** `presentation/games/*` (puzzle, sorting, maze, quiz), `GameId`.
- **Добавляем:**
  - модель `Game` (id, title по текущему языку, url, sfSymbol, maxPoints);
  - `GamesRepository` / `FirestoreGamesRepository`;
  - `FetchGamesUseCase`;
  - хаб по каталогу, рекорды остаются в SwiftData по `gameId`.
- **`GameWebScreen`:** `WKWebView` в `UIViewRepresentable`.
  - URL: `https://chatroom-85fb8.web.app/<path>?lang=<ru|be|en>&theme=<light|dark>`.
  - `WKScriptMessageHandler "greenPassport"` → `SubmitGameResultUseCase`, затем нативный баннер «+N очков».
  - Состояния: загрузка, ошибка сети с «Повторить».
  - Тема и язык передаются из приложения.
- **Хост игр** — `GAMES_BASE_URL` в `Info.plist` через build setting, как `GOOGLE_REVERSED_CLIENT_ID`.

---

## Этап E. Проверка отступов

### Почему
Правки дизайна уходили вслепую: на экране их проверял только пользователь. Simulator.app не найден, симулятор удалён.

### Что делаем
- Создать симулятор `xcrun simctl create "iPhone 17 Simulator" "iPhone 17" com.apple.CoreSimulator.SimRuntime.iOS-27-1`.
- **UI-тест таргет** `Green PassportUITests` (правка `project.pbxproj`, файлы в `Green PassportUITests/`, отдельная синхронизированная группа):
  - тест проходит онбординг → вход гостем → все вкладки и экраны главной, профиля, магазина, игр;
  - на каждом экране делает `XCTAttachment(screenshot:)` в светлой и тёмной теме;
  - скриншоты выгружаются из `.xcresult` через `xcrun xcresulttool`.
- **Просмотр скриншотов и правки:**
  - общий горизонтальный отступ `Spacing.screenHorizontal` везде;
  - одинаковые внутренние отступы карточек (`Spacing.medium`);
  - отступы между карточками `Spacing.small`;
  - высота строк списков;
  - отступы у шапок и safe area.
- **В `CLAUDE.md`:** команда запуска UI-тестов и правило «после правки UI — прогнать скриншот-тест».

---

## Порядок и коммиты
Этапы идут в порядке A → E. На каждый этап отдельный коммит в iOS-репо и, где меняется бэкенд, в Android-репо. Правила коммитов из `CLAUDE.md`, адрес `romangorbachev2006@gmail.com`.

Деплой делает пользователь или я, но только после отдельного подтверждения:
- `firebase deploy --only functions,firestore:rules,hosting --project chatroom-85fb8`;
- повторный сид каталога игр и `validityDays`.

После каждого этапа обновляются `claude/ux-spec.ru.md` (в обоих репо) и `CLAUDE.md`.

## Проверка
1. iOS: `xcodebuild … -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build` и `… test` (UI-скриншоты), без предупреждений.
2. Бэкенд: `cd functions && npm run build && npm test`, затем `firebase emulators:exec --only auth,firestore,functions,storage "npm --prefix functions run test:integration"`.
3. Игры: открыть каждую `games/<id>/index.html?lang=ru&theme=dark` в браузере. `finish(score)` вызывается, вёрстка есть на 375 и 430 pt.
4. Сценарии на симуляторе:
   - фильтр «Выполненные + QR + Гомель» даёт ожидаемый список;
   - покупка купона → шторка с кодом и QR → «Использован» → купон во вкладке «Использованные»;
   - `checkInEvent` с QR из `scripts/qr/` → очки начислены один раз;
   - первая активность дня → +5 за серию;
   - веб-игра → результат → баланс вырос, рекорд сохранён.
