# План: карточка прогресса без дублей, шторка серии с напоминанием, красная кнопка «Выход»; завершение переноса на Android

После одобрения план сохраняется в `claude/streak-sheet-plan.ru.md` (iOS) первым действием. Изменения UX сначала вносятся в `claude/ux-spec.ru.md` (обе копии), отличия для Android — в «Android backlog».

## Контекст

Замечания пользователя по iOS:
1. **Карточка прогресса перегружена текстом.**
   - Сейчас в ней: «Уровень N», капсула «5 дней», очки, полоса XP, подпись «320/1000 XP» и пузырь маскота «680 XP до уровня 5».
   - Подпись под полосой и пузырь говорят одно и то же.
2. **Идея — показать стрик в Dynamic Island.** Обсудили и выбрали другое решение.
   - Dynamic Island показывает только Live Activities, а они по HIG — для текущих событий с концом (доставка, таймер); постоянная серия туда не подходит.
   - Нужны отдельный widget-extension таргет, App Group и правки проекта.
   - На Android аналога нет.
   - Решение пользователя: **шторка серии по нажатию на карточку и вечернее локальное напоминание, если серия под угрозой.**
3. **«Выход» в профиле разноцветный:** текст красный, иконка цвета акцента. Нужен один красный цвет.

**Незавершённая работа.** Перенос на Android (`claude/android-port-plan.ru.md` в Android-репо) реализован в коде и компилируется (`compileDebugKotlin`). Не сделаны последние шаги — они идут первыми.

---

## 0. Завершить перенос на Android

**Почему первым:** код Android уже изменён и не закоммичен.

1. `./gradlew build` и `./gradlew detektAll`:
   - находки исправляются;
   - форматирование — `./gradlew detektAll -PdetektAutoFix`;
   - baseline не трогаем.
2. Спецификация (обе копии): 12 пунктов Android backlog → `[x]`. Раздел 1 уточняется до поведения, а в «Сознательные различия платформ» добавляется строка: iOS выбирает язык контента в маппере, Android — при отображении.
3. Android `CLAUDE.md`: `LocalizedText` / `localized()`, `cityName()`, `LoadingLabel`, `MonthCalendar`, `ArticleText`, `GameTile`.
4. Коммит в Android-репо.

## 1. Карточка прогресса без дублей (iOS)

**Почему:** число до следующего уровня уже есть в пузыре маскота, поэтому подпись «xp/1000» под полосой — лишняя строка. Слово «дней» в капсуле тоже лишнее: подробности серии теперь в шторке.

`presentation/components/ProgressHeroCard.swift`:
- удаляется `Text(.xpProgress(...))` под полосой;
- капсула серии — «🔥 5»: число без слова, `accessibilityLabel(Text(.streakDays(streakDays)))`;
- новый необязательный `onTap`. Если он задан, карточка — кнопка с подсказкой доступности `streak_open_hint`, без изменения вида.

```swift
@ViewBuilder
private var streakBadge: some View {
    if streakDays > 0 {
        Label {
            Text(streakDays, format: .number)
        } icon: {
            Image(systemName: "flame.fill")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Palette.onLime)
        .padding(.horizontal, Spacing.xSmall)
        .padding(.vertical, Spacing.hairline)
        .background(Palette.lime, in: .capsule)
        .accessibilityLabel(Text(.streakDays(streakDays)))
    }
}
```

На главной: `ProgressHeroCard(points:level:streakDays:onTap: { isStreakSheetPresented = true })`. Магазин и профиль `onTap` не передают. Строка `xp_progress` удаляется, если больше нигде не используется (проверить grep).

## 2. Шторка серии (iOS)

**Почему:** серия хранится как `{count, lastDay}`, а её дни по определению идут подряд. Значит, последние `count` дней до `lastDay` известны точно, и неделю можно нарисовать без новых данных с сервера. Бонус +35 начисляется на каждый 7-й день подряд (`claude/points-economy.ru.md`).

**Логика** — `presentation/home/states/StreakSummary.swift`, чистая структура, считается из `Streak` и текущей даты по Europe/Minsk, как `Streak.currentCount`:

```swift
nonisolated struct StreakSummary: Hashable, Sendable {
    let days: Int
    let isTodayCounted: Bool
    let daysUntilBonus: Int
    let week: [StreakWeekDay]
}

nonisolated struct StreakWeekDay: Hashable, Sendable, Identifiable {
    let date: Date
    let isActive: Bool
    let isToday: Bool
    var id: Date { return date }
}
```

`StreakWeekDay` лежит в отдельном файле. Расчёт — `extension Streak { func summary(at date: Date, calendar: Calendar) -> StreakSummary }` в `presentation/home/states/Streak+Summary.swift`:
- `isTodayCounted = lastDay == today`;
- активные дни — `count` дней, заканчивающихся на `lastDay`;
- неделя — с первого дня недели по локали;
- `daysUntilBonus`: следующий 7-й день считается от `days`, а если сегодня ещё не засчитан — от `days + 1`.

**`presentation/home/ui/StreakSheet.swift`** — шторка `.presentationDetents([.medium])`:
- крупно «🔥 5 дней подряд» (`streak_days_in_row`, плюрализация);
- лента из 7 кружков с буквами дней недели: активный день — Lime с огнём, сегодня — обводка Forest;
- статус: `streak_today_counted` («Сегодня уже засчитан») или `streak_today_pending` («Сделайте что-нибудь сегодня, чтобы не потерять серию»);
- `streak_bonus_in_days` («До бонуса +35 — 2 дня»);
- `streak_rule` мелким текстом: «Первая активность дня даёт +5, каждый 7-й день подряд — ещё +35».

`HomeUiState` хранит `streak: Streak?` (вместо одного числа), а `streakDays` становится вычисляемым. Шторка подключается в `HomeRoute` через `@State isStreakSheetPresented`.

Строки ru/be/en — все новые ключи в `Localizable.xcstrings`.

## 3. Вечернее напоминание о серии (iOS)

**Почему локальное:** пушей в проекте нет (CLAUDE.md), а локальные уведомления уже есть: `LocalNotificationReminderScheduler`, переключатель `notifications_enabled`, запрос разрешения при первом использовании.

**Правило:** если серия жива (`currentCount > 0`), сегодня активности ещё не было (`lastDay != сегодня`) и сейчас раньше 20:00, то на сегодня в 20:00 стоит одно уведомление `streak_reminder`. Во всех остальных случаях оно снимается.
- Перепланирование происходит при каждом обновлении кошелька: после любой оплачиваемой активности `lastDay` становится сегодняшним, и напоминание снимается само.
- **В журнал уведомлений не пишется**, в отличие от событий и купонов. Оно переставляется и снимается, поэтому запись при планировании оставила бы в журнале уведомления, которые не приходили.

`domain/repositories/ReminderScheduler.swift` получает:

```swift
func scheduleStreakReminder(streakDays: Int, at date: Date) async
func cancelStreakReminder()
```

`domain/usecases/home/UpdateStreakReminderUseCase.swift`:

```swift
final class UpdateStreakReminderUseCase {
    private static let reminderHour = 20

    private let reminderScheduler: ReminderScheduler

    init(reminderScheduler: ReminderScheduler) {
        self.reminderScheduler = reminderScheduler
    }

    func execute(streak: Streak?, now: Date) async {
        let calendar = Calendar.minsk
        guard let streak,
              streak.currentCount(at: now) > 0,
              !streak.isCounted(on: now),
              let fireDate = calendar.date(bySettingHour: Self.reminderHour, minute: 0, second: 0, of: now),
              fireDate > now else {
            reminderScheduler.cancelStreakReminder()
            return
        }
        await reminderScheduler.scheduleStreakReminder(streakDays: streak.count, at: fireDate)
    }
}
```

**Вспомогательные части:**
- `Calendar.minsk` — небольшое расширение в `domain/models/Calendar+Minsk.swift` с часовым поясом Europe/Minsk; `Streak+Current` переходит на него;
- `isCounted(on:)` — в том же `Streak+Current.swift`.

**`LocalNotificationReminderScheduler`:**
- общий `schedule` разделяется на `deliver` (проверка переключателя и разрешения, постановка запроса) и запись в журнал;
- напоминание о серии вызывает только `deliver`;
- текст: `streak_reminder_title` («Серия под угрозой 🔥»), `streak_reminder_body` («%lld дней подряд — сделайте одно эко-действие до конца дня»).

`HomeViewModel.observeWallet` после обновления состояния вызывает use case. Фабрика — в `AppDIContainer`. Выключение уведомлений в профиле снимает и это напоминание: используется существующий путь отмены, плюс проверка в `deliver`.

## 4. Красная кнопка «Выход» (iOS)

**Почему:** у `Button(role: .destructive)` внутри `Label` текст красный, а иконка берёт цвет акцента списка.

`presentation/profile/ui/ProfileScreen.swift`:

```swift
Button(role: .destructive) {
    onAction(.signOut)
} label: {
    Label {
        Text(.profileSignOut)
    } icon: {
        Image(systemName: "rectangle.portrait.and.arrow.right")
    }
    .foregroundStyle(Palette.error)
}
```

## 5. Спецификация

- **6.4, главная:**
  - карточка прогресса без подписи «xp/1000»;
  - капсула серии «🔥 N»;
  - нажатие на карточку открывает шторку серии (неделя, статус дня, дни до бонуса, правило);
  - вечернее напоминание в 20:00, если серия под угрозой; напоминание не попадает в журнал.
- **Раздел 4, компоненты:** строка «Карточка прогресса» обновляется.
- **6.8, профиль:** «Выход» — текст и иконка цвета ошибки.
- **Android backlog:** карточка без дублей, шторка серии, напоминание (WorkManager, как напоминания о событиях), красный «Выход».

---

## Порядок работ

1. Шаг 0 — завершить Android (build, detekt, спецификация, CLAUDE.md, коммит).
2. План → `claude/streak-sheet-plan.ru.md`, спецификация (обе копии).
3. iOS: «Выход» → карточка → `StreakSummary` и шторка → напоминание. Сборка после каждого шага.
4. Коммит iOS.

## Проверка

```bash
./gradlew build && ./gradlew detektAll      # Android, шаг 0
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

Сборка iOS без предупреждений из кода проекта. Расчёт `StreakSummary` проверяется превью шторки с несколькими состояниями: серия 5 и сегодня засчитан; серия 6 и сегодня нет — до бонуса 1 день; серия 0.

Ручные сценарии (у пользователя на симуляторе, светлая и тёмная тема):
1. **Карточка:** нет «xp/1000», капсула «🔥 5», пузырь маскота на месте.
2. **Шторка:**
   - нажатие на карточку на главной открывает шторку;
   - отмечены нужные дни недели, статус дня и «до бонуса» верные.
3. **Напоминание:**
   - при живой серии и без активности сегодня в «Настройки → Уведомления» ожидает запрос `streak_reminder` на 20:00;
   - после выполнения задания запрос пропадает;
   - при выключенном переключателе уведомлений не ставится.
4. **Профиль:** «Выход» — красные и текст, и иконка.
