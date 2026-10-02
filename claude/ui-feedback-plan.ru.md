# План: правки UX по отзыву (кнопки, плитки, профиль, календарь, игры, статьи)

После одобрения план копируется в `claude/ui-feedback-plan.ru.md` первым действием. Все изменения UX сначала вносятся в `claude/ux-spec.ru.md` (и в его копию в Android-репо), отличия для Android добавляются в раздел «Android backlog».

## Контекст

Пользователь посмотрел приложение и прислал 7 замечаний. Что нашлось в коде:

1. **Кнопка растёт во время загрузки.** `AppButton` задаёт `.controlSize(.large)` на всю кнопку, и этот размер достаётся `ProgressView`. Большой спиннер выше строки `.headline`, поэтому `ZStack` и вместе с ним кнопка становятся выше. То же в `MessageComposer`: там спиннер подменяет стрелку в круглой кнопке. В `GroupsScreen` (кнопка «Создать», «Вступить по коду») и `FeedbackScreen` кнопку целиком заменяет спиннер, и ширина прыгает.
2. **Иконки форума и групп слишком крупные.** `SymbolTile` задаёт символу размер шрифта `size * 0.5`. Широкие символы (`bubble.left.and.bubble.right.fill`, `person.3.fill`) при этом почти заполняют плитку по ширине.
3. **«Мои карты» дублируют «Достижения».** `CardsRoute` использует тот же `AchievementsViewModel`, просто показывает сеткой. «Обмен картами» — заглушка без данных. Решение: убрать «Мои карты» и «Обмен», а «Достижения» сделать сеткой карточек с прогрессом.
4. **«Избранное» и «Закладки» в профиле** открывают ту же вкладку «Избранное» с разными выбранными сегментами. Решение: убрать обе строки из профиля.
5. **«Календарь» без календаря.** `CalendarScreen` — просто лента карточек событий. Решение: системный месячный календарь (`UICalendarView`), на днях с событиями точки, под ним события выбранного дня.
6. **Игры.** 8 простых DOM-игр на 100–170 строк, почти без анимации. Решение: заменить их на 5 новых игр на canvas с общим движком (анимация, частицы, звук, вибрация).
7. **Статьи — одна строка.** Статьи — это `ecoTips` (категории ARTICLE/VIDEO/KIDS), в `body` одно предложение, у VIDEO ссылки-заглушки `youtu.be/example-…`. Решение: полный текст в Markdown на ru/be/en, обложка, «N мин чтения», превью в списке.

---

## 1. Размер кнопки не меняется во время загрузки

**Почему:** спиннер не должен влиять на раскладку. Подпись остаётся в разметке (прозрачной), а маленький спиннер кладётся поверх неё через `overlay`. Один общий модификатор используется везде, где кнопка что-то загружает.

Новый файл `presentation/components/View+LoadingOverlay.swift`:

```swift
import SwiftUI

extension View {
    func loadingOverlay(_ isLoading: Bool, tint: Color? = nil) -> some View {
        return self
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(tint)
                }
            }
    }
}
```

`AppButton`:

```swift
Button(action: action) {
    Text(title)
        .font(.headline)
        .loadingOverlay(isLoading, tint: Palette.onForest)
        .frame(maxWidth: .infinity)
}
.buttonStyle(.glassProminent)
.controlSize(.large)
.disabled(!isEnabled || isLoading)
```

`MessageComposer`: стрелка остаётся в кнопке, спиннер лежит поверх:

```swift
Button(action: onSend) {
    Image(systemName: "arrow.up")
        .font(.headline)
        .loadingOverlay(isSending, tint: Palette.onForest)
}
```

В `GroupsScreen` (создать группу, «Вступить» в строке, «Вступить по коду» в тулбаре) и в `FeedbackScreen` спиннер больше не подменяет кнопку. Кнопка остаётся на месте, выключена (`.disabled`), а её подпись получает `.loadingOverlay(...)`. В `ShopScreen` (кнопка «Купить») то же самое.

## 2. Иконки в плитках меньше, фон тот же

**Почему:** размер шрифта символа не ограничивает его ширину, поэтому широкие символы распирают плитку. Символ нужно вписать в квадрат `size * symbolScale`: тогда у широких символов ограничением будет ширина, у узких — высота, и визуально все символы будут одного размера. Заодно `defaultSymbolScale` уменьшается с 0.5 до 0.42. Фон плитки и её размер не меняются.

```swift
struct SymbolTile: View {
    static let defaultSymbolScale: CGFloat = 0.42
    private static let cornerScale: CGFloat = 0.28

    let systemImage: String
    var style: SymbolTileStyle = .accent
    var size: CGFloat = 32
    var symbolScale: CGFloat = SymbolTile.defaultSymbolScale

    var body: some View {
        RoundedRectangle(cornerRadius: size * Self.cornerScale, style: .continuous)
            .fill(style.background)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.semibold)
                    .frame(width: size * symbolScale, height: size * symbolScale)
                    .foregroundStyle(style.foreground)
            }
            .accessibilityHidden(true)
    }
}
```

Это затрагивает все плитки: хаб сообщества, список групп, шапку группы, профиль, игры, достижения. На главной масштаб иконок свой (`quickActionSymbolScale = 0.38`), там иконки внутри того же бокса станут чуть меньше. Это проверяется на скриншоте, при необходимости поднять значение до 0.45. В спецификацию в таблицу компонентов (раздел 3) добавляется строка «символ вписан в квадрат 42 % плитки».

## 3. «Достижения» вместо «Мои карты» и «Обмен»

**Почему:** у двух экранов одни и те же данные, а «Обмен картами» без карт не имеет смысла. Один экран «Достижения» показывает больше: условие и прогресс до цели.

**Удаляется:** `CardsScreen`, `CardsRoute`, `ExchangeScreen`, кейсы `AppDestination.cards` / `.exchange`, `ProfileMenuEntry.cards` / `.exchange`, строки `profile_cards`, `cards_screen_title`, `cards_locked_label`, `profile_exchange`, `exchange_screen_title`, `exchange_unavailable_message`.

**Модель с прогрессом** (`domain/models/Achievement.swift`):

```swift
nonisolated struct Achievement: Identifiable, Hashable, Sendable {
    let id: AchievementId
    let progress: Int
    let target: Int

    var isUnlocked: Bool {
        return progress >= target
    }
}
```

`DerivedAchievementsRepository` вместо булева значения отдаёт прогресс:

```swift
return AchievementId.allCases.map { id in
    switch id {
    case .firstTask:
        return Achievement(id: id, progress: completedCount, target: Self.firstTaskThreshold)
    case .taskMaster:
        return Achievement(id: id, progress: completedCount, target: Self.taskMasterThreshold)
    case .eventGoer:
        return Achievement(id: id, progress: registeredCount, target: Self.eventGoerThreshold)
    case .ecoReader:
        return Achievement(id: id, progress: readCount, target: Self.ecoReaderThreshold)
    case .communityMember:
        return Achievement(id: id, progress: isGroupMember ? 1 : 0, target: Self.communityMemberThreshold)
    case .levelFive:
        return Achievement(id: id, progress: level.number, target: Self.levelFiveThreshold)
    }
}
```

**Экран** — сетка 2×N карточек. У каждого достижения свой символ (`AchievementId.systemImage` рядом с `title`/`details` в `AchievementId+Texts.swift`: `leaf.fill`, `checkmark.seal.fill`, `calendar.badge.checkmark`, `book.fill`, `person.3.fill`, `star.fill`). Открытое достижение — плитка `.prominent` и карточка `MintSurface`, закрытое — плитка `.muted`, полоса прогресса Forest и подпись `achievement_progress_format` «%1$lld из %2$lld». Сверху счётчик `achievements_unlocked_format` «Открыто %1$lld из %2$lld».

```swift
private func card(_ achievement: Achievement) -> some View {
    return VStack(alignment: .leading, spacing: Spacing.xSmall) {
        SymbolTile(
            systemImage: achievement.id.systemImage,
            style: achievement.isUnlocked ? .prominent : .muted,
            size: Self.tileSize
        )
        Text(achievement.id.title)
            .font(.headline)
        Text(achievement.id.details)
            .font(.footnote)
            .foregroundStyle(Palette.secondaryText)
        Spacer(minLength: 0)
        if achievement.isUnlocked {
            Label { Text(.achievementUnlockedLabel) } icon: { Image(systemName: "checkmark.circle.fill") }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Palette.forest)
        } else {
            ProgressView(value: Double(min(achievement.progress, achievement.target)), total: Double(achievement.target))
                .tint(Palette.forest)
            Text(.achievementProgressFormat(min(achievement.progress, achievement.target), achievement.target))
                .font(.caption)
                .foregroundStyle(Palette.secondaryText)
        }
    }
    .padding(Spacing.medium)
    .frame(maxWidth: .infinity, minHeight: Self.cardMinHeight, alignment: .topLeading)
    .background(
        achievement.isUnlocked ? Palette.mintSurface : Palette.cardBackground,
        in: .rect(cornerRadius: CornerRadius.large, style: .continuous)
    )
    .accessibilityElement(children: .combine)
}
```

Спецификация, 6.8 и 6.9: убрать карты и обмен, описать сетку достижений с прогрессом. Backlog Android: то же.

## 4. «Избранное» и «Закладки» убираются из профиля

**Почему:** вкладка «Избранное» уже есть в таб-баре с сегментами «Задания» / «Советы». Две строки в профиле ведут на тот же экран и путают.

- `ProfileMenuEntry`: удалить `.favorites` и `.bookmarks`.
- `AppDestination.favorites(FavoritesSegment)` больше не нужен, если на него не ссылается ничего, кроме профиля (проверить grep'ом). Если ссылок нет, удалить кейс и ветку в `AppDestinationView`.
- Строки `profile_favorites` и `profile_bookmarks` удалить из `Localizable.xcstrings`.
- Спецификация 6.8 и 6.13: убрать фразу «Из меню профиля открывается тот же экран…». Backlog Android: то же.

## 5. Календарь — настоящий календарь

**Почему:** экран называется «Календарь», но месяца на нём нет. Системный `UICalendarView` нативен (HIG), сам листает месяцы, поддерживает Dynamic Type и тёмную тему, а на днях с событиями умеет рисовать точки (decorations).

Новый компонент `presentation/calendar/ui/EventCalendarView.swift` — `UIViewRepresentable`. Внутри приватный `Coordinator`, допустимое исключение из правила «один тип на файл».

```swift
import SwiftUI
import UIKit

struct EventCalendarView: UIViewRepresentable {
    let eventDays: Set<DateComponents>
    @Binding var selectedDay: DateComponents

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = .current
        calendarView.tintColor = UIColor(Palette.forest)
        calendarView.delegate = context.coordinator
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = selectedDay
        calendarView.selectionBehavior = selection
        calendarView.setContentHuggingPriority(.required, for: .vertical)
        return calendarView
    }

    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        let previousDays = context.coordinator.eventDays
        context.coordinator.parent = self
        context.coordinator.eventDays = eventDays
        let changedDays = previousDays.symmetricDifference(eventDays)
        if !changedDays.isEmpty {
            calendarView.reloadDecorations(forDateComponents: Array(changedDays), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: EventCalendarView
        var eventDays: Set<DateComponents>

        init(parent: EventCalendarView) {
            self.parent = parent
            self.eventDays = parent.eventDays
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard eventDays.contains(EcoEvent.dayComponents(of: dateComponents)) else {
                return nil
            }
            return .default(color: UIColor(Palette.forest), size: .medium)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents else {
                return
            }
            parent.selectedDay = EcoEvent.dayComponents(of: dateComponents)
        }
    }
}
```

`EcoEvent+Schedule.swift` получает функцию нормализации дня (только `year/month/day`, иначе `Set` не совпадёт с компонентами из `UICalendarView`):

```swift
static func dayComponents(of components: DateComponents) -> DateComponents {
    return DateComponents(year: components.year, month: components.month, day: components.day)
}

var dayComponents: DateComponents {
    return Calendar.current.dateComponents([.year, .month, .day], from: startAt)
}
```

`CalendarScreen` (ScrollView): сверху `EventCalendarView` в карточке `CardBackground`, под ним заголовок секции с выбранной датой (`Text(date, format: .dateTime.day().month(.wide).weekday(.wide))`) и карточки событий этого дня (тот же `HeroImageCard`, высота 160). Если в выбранный день событий нет, показывается `calendar_no_events_on_day` «В этот день событий нет». Выбранный день хранится в `CalendarRoute` (`@State`). Начальное значение — ближайший день с событием, начиная с сегодня, а если таких нет — сегодня. Его считает `CalendarViewModel` при первом `.success`:

```swift
private(set) var selectedDay: DateComponents = EcoEvent.dayComponents(of: Calendar.current.dateComponents([.year, .month, .day], from: .now))
private var hasChosenInitialDay = false

func selectDay(_ day: DateComponents) {
    selectedDay = day
}

private func chooseInitialDay(from events: [EcoEvent]) {
    guard !hasChosenInitialDay else {
        return
    }
    hasChosenInitialDay = true
    let startOfToday = Calendar.current.startOfDay(for: .now)
    if let nextEvent = events.first(where: { return $0.startAt >= startOfToday }) {
        selectedDay = nextEvent.dayComponents
    }
}
```

Спецификация 6.11 переписывается. Backlog Android: месячный календарь Material 3 (`DatePicker` без диалога не умеет рисовать точки, нужна своя сетка месяца).

## 6. Новые игры (Android-репо `games/`, общие для обеих платформ)

**Почему:** нынешние игры — статичные DOM-формы. Canvas с игровым циклом даёт плавную анимацию, частицы, параллакс и «сочный» отклик. Игры живут на Firebase Hosting, поэтому замена не требует релиза приложений. Мост (`finish` / `close`), параметры `lang` / `theme` и жизни сохраняются, так что код iOS и Android не меняется.

**Общий движок** `games/common/engine.js` (ES-модуль, без зависимостей и сборки) рядом с существующими `game.js` / `theme.css`:
- `createStage(canvas)` — масштаб под `devicePixelRatio`, ресайз, safe area;
- `loop(update, render)` — `requestAnimationFrame` с `dt`, пауза при `visibilitychange`;
- ввод: `onTap`, `onSwipe(dir)`, `onDrag(x, y)` на pointer events;
- `particles` (брызги, листья, конфетти), `tween` / `ease` (outBack, outCubic), `shake`, `floatingText("+1")`;
- `sound` — короткие синтезированные звуки на WebAudio (без файлов), включаются после первого касания;
- `startScreen(title, hint)` — анимированный маскот и «Коснись, чтобы начать».

Цвета берутся из токенов `theme.css` (светлая и тёмная тема), отходы рисуются эмодзи (🍾 🥫 📰 🍌 🔋), остальное — векторными фигурами.

```js
import { createStage, loop, particles, onTap, sound } from '../common/engine.js';
import * as GP from '../common/game.js';

const stage = createStage(document.querySelector('canvas'));
const lives = GP.lives(document.querySelector('.hud'), gameOver);
let score = 0;

onTap(stage, () => player.jump());

loop((dt) => {
  world.update(dt);
  for (const hit of world.collisions(player)) {
    if (hit.kind === 'leaf') {
      score += 1;
      particles.burst(hit.x, hit.y, 'leaf');
      sound.pick();
    } else {
      lives.lose();
      stage.shake();
    }
  }
}, () => world.render(stage));

function gameOver() {
  GP.finish(score);
  GP.showResult(GP.t('score', score), restart);
}
```

**Пять игр** (очко в игре = 1 балл, сервер начисляет min(score, 30)):

| id | Название ru / be / en | Механика | Очко за | Жизни |
|---|---|---|---|---|
| `eco_runner` | Эко-забег / Эка-забег / Eco run | Маскот бежит, параллакс леса; тап — прыжок (двойной прыжок), скорость растёт | собранный лист | столкновение с кучей мусора |
| `sort_conveyor` | Сортировочный конвейер / Сартавальны канвеер / Sorting line | Отходы едут по ленте; свайп или тап по одному из 4 баков, предмет летит в бак по дуге, комбо ×2 / ×3 | верная сортировка | неверный бак или предмет уехал |
| `ocean_cleanup` | Чистый океан / Чысты акіян / Ocean cleanup | Ведёшь лодку с сетью пальцем, волны и пузыри; пластик всплывает, рыбы проплывают | пойманный пластик | пойманная рыба |
| `forest_guard` | Лесной патруль / Лясны патруль / Forest guard | Поле 4×4 саженцев растёт по стадиям; тапом тушишь искры и прогоняешь жуков, пока не перекинулись | выросшее дерево | сгоревший саженец |
| `eco_merge` | Эко-2048 / Эка-2048 / Eco merge | Свайпы 4×4: семя → росток → куст → дерево → роща → лес, плавное скольжение и «поп» слияния | 1 за каждое слияние уровня ≥ 3 | нет (конец — нет ходов) |

**Каталог** (`scripts/seed-firestore.js`): 5 новых документов с фиксированными id, `sfSymbol` / `materialIcon` (`figure.run` / `DirectionsRun`, `shippingbox.fill` / `Inventory`, `water.waves` / `Waves`, `tree.fill` / `Forest`, `square.grid.2x2.fill` / `GridView`), `maxPoints: 30`, `order` 1–5. Старые 8 документов получают `isActive: false`, их папки удаляются. Локальные рекорды старых игр останутся в SwiftData — это безвредно. В Android `GameIcon.kt` нужно добавить 5 новых иконок, это пункт backlog.

Спецификация 6.17: новый список игр и правила жизней.

## 7. Статьи: полный текст, обложка, время чтения, превью

**Почему:** сейчас у статьи одно предложение, и читать нечего. VIDEO-ссылки ведут на несуществующие ролики.

**Данные** (`ecoTips`, обратно совместимо): `title` / `body` остаются (ru, фолбэк для старых клиентов), добавляются необязательные `titles{ru,be,en}`, `bodies{ru,be,en}` (Markdown: абзацы, `## подзаголовки`, `- списки`, **жирный**) и `imageUrl`. В seed у документов фиксированные id (`plastic_sorting`, …), чтобы повторный запуск перезаписывал, а не дублировал. Тексты: 7 статей по 5–10 абзацев на трёх языках. Обложки: фото с Unsplash (лицензия позволяет), скачанные в Hosting `games/covers/<id>.jpg` (около 1200 px, до 200 КБ). Ссылки VIDEO заменяются на реальные проверенные ролики, иначе `mediaUrl: null`.

**Модель** `EcoTip` (+ `titles`, `bodies`, `imageUrl`), маппинг в `FirestoreEcoTipsRepository` по образцу `FirestoreGamesRepository`:

```swift
private static let fieldTitles = "titles"
private static let fieldBodies = "bodies"
private static let fieldImageUrl = "imageUrl"

titles: document.get(Self.fieldTitles) as? [String: String] ?? [:],
bodies: document.get(Self.fieldBodies) as? [String: String] ?? [:],
imageUrl: document.string(Self.fieldImageUrl),
```

`presentation/ecotips/states/EcoTip+Localized.swift` (по образцу `Game+Title.swift`):

```swift
extension EcoTip {
    private static let wordsPerMinute = 180
    private static let previewSeparator = "\n\n"

    var localizedTitle: String {
        return titles[AppLanguage.currentCode] ?? title
    }

    var localizedBody: String {
        return bodies[AppLanguage.currentCode] ?? body
    }

    var readMinutes: Int {
        let wordCount = localizedBody.split(whereSeparator: \.isWhitespace).count
        return max(1, Int((Double(wordCount) / Double(Self.wordsPerMinute)).rounded(.up)))
    }

    var preview: String {
        let firstParagraph = localizedBody.components(separatedBy: Self.previewSeparator)
            .first { return !$0.hasPrefix("#") } ?? localizedBody
        let attributed = try? AttributedString(markdown: firstParagraph)
        return attributed.map { return String($0.characters) } ?? firstParagraph
    }
}
```

**Рендер Markdown.** `Text(AttributedString(markdown:))` понимает только строчную разметку, поэтому `MarkdownArticleView` (`presentation/ecotips/ui/`) делит текст на блоки. `ArticleBlock` — enum в отдельном файле `states/ArticleBlock.swift`: `.heading`, `.paragraph`, `.bullet`. Каждый блок рисуется своим стилем: `.title3.bold()`, `.body`, строка с «•». Внутри блоков строчная разметка (`**`, `_`, ссылки) идёт через `AttributedString(markdown:)`.

```swift
nonisolated enum ArticleBlock: Hashable, Sendable {
    case heading(String)
    case paragraph(String)
    case bullet(String)

    private static let headingPrefix = "## "
    private static let bulletPrefix = "- "

    static func parse(_ markdown: String) -> [ArticleBlock] {
        return markdown.components(separatedBy: "\n")
            .map { return $0.trimmingCharacters(in: .whitespaces) }
            .filter { return !$0.isEmpty }
            .map { line in
                if line.hasPrefix(headingPrefix) {
                    return .heading(String(line.dropFirst(headingPrefix.count)))
                }
                if line.hasPrefix(bulletPrefix) {
                    return .bullet(String(line.dropFirst(bulletPrefix.count)))
                }
                return .paragraph(line)
            }
    }
}
```

**Экран статьи** (`EcoTipDetailScreen`): сверху обложка во всю ширину (`AsyncImage`, высота 220, без обложки — градиент Forest с символом категории), затем строка «категория · N мин чтения» (`ecotip_read_minutes_format` «%1$lld мин чтения»), заголовок `localizedTitle`, `MarkdownArticleView`, для VIDEO — кнопка `watch_video` вместо голого URL, строка награды, внизу прежняя кнопка «Прочитано».

**Список** (`EcoTipsListScreen`): строка — миниатюра обложки 64×64 (без обложки — `SymbolTile` категории), заголовок, 2 строки `preview`, мета «категория · N мин» и отметка «прочитано» (галочка Forest). Справа закладка. Карточка «Совет дня» показывает `preview` вместо сырого `body`. В «Избранном» (сегмент «Советы») — `localizedTitle`.

Спецификация 6.15: обложка, время чтения, превью, Markdown, локализованные поля. Backlog Android: `titles` / `bodies` / `imageUrl`, рендер Markdown, превью.

---

## Порядок работ

1. Скопировать план в `claude/ui-feedback-plan.ru.md`.
2. Обновить `claude/ux-spec.ru.md` в обоих репозиториях (разделы 3, 6.8, 6.9, 6.11, 6.13, 6.15, 6.17 и backlog).
3. iOS: пункты 1 → 2 → 4 → 3 → 5 → 7, сборка после каждого.
4. Android-репо: движок и 5 игр, тексты и обложки статей, seed.
5. Перед `firebase deploy --only hosting` и запуском `node scripts/seed-firestore.js --only=games,ecoTips` — спросить подтверждение: это изменения в общем проде.
6. Коммиты по формату CLAUDE.md, отдельно в каждом репозитории.

## Проверка

Сборка:

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

Ручные сценарии на симуляторе (светлая и тёмная тема):
1. Совет → «Отметить прочитанным», вход / регистрация, отправка сообщения на форуме, «Создать группу»: во время загрузки высота и ширина кнопки не меняются, спиннер маленький.
2. Сообщество: иконки форума и групп заметно меньше, фон плиток тот же. Профиль и игры выглядят ровно.
3. Профиль: нет строк «Мои карты», «Обмен», «Избранное», «Закладки». «Достижения» — сетка с прогрессом «2 из 5». После выполнения задания счётчик растёт.
4. Календарь: месяц с точками на днях событий, открыт ближайший день с событием, переключение дня меняет список, пустой день показывает «В этот день событий нет», тап по событию открывает шторку.
5. Игры: в хабе 5 новых игр. Каждая запускается, анимации плавные (60 fps), жизни работают, итог → баннер начисления очков, «Закрыть» закрывает. Проверить и в браузере (`npx serve games`) через `?lang=en&theme=dark`.
6. Статьи: в списке обложки, превью в 2 строки, «N мин». В статье обложка, подзаголовки, списки, жирный текст. Язык be / en (смена в Настройках) — переведённый текст. Видео открывает реальный ролик.

## Отклонения при реализации

- `FeedbackScreen`: кнопки отправки — строки формы, подпись прятать нельзя, поэтому там спиннер остался справа, но стал маленьким (`.controlSize(.small)`), и высота строки не меняется.
- `profile_favorites` / `profile_bookmarks` не удалены из каталога строк: это подписи доступности у сердца и закладки.
- Выбранный день календаря хранит `CalendarViewModel` (`selectDay`), `EventCalendarView` получает день и замыкание вместо `Binding`, нормализация дня — `DateComponents+Day.swift`.
- `games/common/engine.js` — глобальный `Engine` (как `GP`), а не ES-модуль; у каждой игры `index.html` + `main.js`.
- Seed советов не создаёт новые документы, а обновляет существующие по русскому `title` (id и отметки «прочитано» сохраняются); фиксированные id — только в пустом проекте. Поле `body` — тот же текст без Markdown для клиентов, которые ещё не умеют его рисовать.
- Обложки — фото Unsplash в `games/covers/<id>.jpg` (1200×800, до 200 КБ). Видео: Curiosity Quest «how glass is recycled» и «What Happens when a Plastic Bottle is Recycled» (проверены через oEmbed).
