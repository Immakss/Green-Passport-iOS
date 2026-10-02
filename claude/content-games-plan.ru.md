# План: больше игр и контента, перевод контента, правки календаря и темы

После одобрения план копируется в `claude/content-games-plan.ru.md` первым действием. Изменения UX сначала вносятся в `claude/ux-spec.ru.md` (обе копии), отличия для Android — в «Android backlog».

## Контекст

Пользователь просит:
1. **Ещё игр** и для каждой — интересную нажимаемую иконку. Решение: +5 игр (итого 10); хаб — сетка 2×N больших плиток с градиентом и эмодзи из каталога, с анимацией нажатия.
2. **Больше контента, примерно в 3 раза:**
   - задания 10 → 30, во всех 12 городах;
   - статьи 7 → 20;
   - события 4 → 12;
   - магазин 6 → 15;
   - опросы 1 → 3;
   - карта — только проверенные реальные пункты приёма.
3. **Перевод контента на ru/be/en.** Сейчас переведены только названия игр и статьи; задания, события, награды, точки карты, опросы и названия городов — только на русском.
4. **Календарь:**
   - сетке не хватает боковых отступов;
   - на днях показывать число событий, а не точку.
5. **Меню «Тема»:** убрать иконки перед «Системная / Светлая / Тёмная».

Что выяснилось в коде:
- **Seed.** `seed-firestore.js` пишет задания, события, магазин и карту со случайными id: повторный запуск создаёт дубли. Прогресс пользователей (`taskProgress`, регистрации, купоны) ссылается на эти id, поэтому seed должен обновлять документы на месте (по русскому названию), как уже сделано для статей.
- **Опросы.** Ответ на опрос уходит индексом (`optionIndex`), поэтому переведённые варианты безопасны при том же порядке.
- **Язык приложения** — `Bundle.main.preferredLocalizations.first` (`AppLanguage.currentCode`). Он меняется только через системные настройки, и приложение при этом перезапускается. Значит, язык можно выбирать один раз при маппинге документа.

**Шаг 0.** Незакоммиченные исправления предупреждений main actor (16 штук, сборка без предупреждений) коммитятся отдельным коммитом до начала работ.

---

## 1. Меню «Тема» без иконок

**Почему:** в выпадающем списке иконка перед каждым пунктом не нужна; плитка слева от строки уже показывает текущую тему.

`presentation/profile/ui/ProfileScreen.swift`:

```swift
Picker(selection: Binding(get: { return uiState.theme }, set: { onAction(.themeSelected($0)) })) {
    ForEach(AppTheme.allCases, id: \.self) { theme in
        Text(theme.title)
            .tag(theme)
    }
} label: {
    HStack(spacing: Spacing.small) {
        SymbolTile(systemImage: uiState.theme.systemImage, style: .tinted(SectionColor.games), size: Self.tileSize)
        Text(.theme)
    }
}
.pickerStyle(.menu)
```

## 2. Календарь: отступы и число событий

**Почему отступов нет:** у `UICalendarView` большая собственная ширина, и SwiftUI отдаёт ей больше места, чем есть в карточке. Сетка упирается в края. Нужно, чтобы representable брал ширину из предложения SwiftUI (`sizeThatFits`), а внутри карточки был отступ `Spacing.small`.

**Почему число:** точка говорит только «что-то есть»; число сразу показывает, где событий больше. Для этого используется `UICalendarView.Decoration.customView` — маленькая капсула Forest с белой цифрой.

`EventCalendarView` принимает словарь «день → число событий»:

```swift
struct EventCalendarView: UIViewRepresentable {
    let eventCounts: [DateComponents: Int]
    let selectedDay: DateComponents
    let onSelectDay: (DateComponents) -> Void

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        guard let width = proposal.width else {
            return nil
        }
        let height = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return CGSize(width: width, height: height)
    }
}
```

Декорация в `Coordinator`:

```swift
func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
    guard let count = eventCounts[dateComponents.dayOnly] else {
        return nil
    }
    return .customView {
        return EventCountBadge.make(count: count)
    }
}
```

`presentation/calendar/ui/EventCountBadge.swift` — `UILabel` в капсуле. В UIKit нет SwiftUI-токенов, поэтому цвета берутся из `Palette`, а шрифт — Dynamic Type `.caption2`:

```swift
enum EventCountBadge {
    private static let horizontalInset: CGFloat = 5
    private static let minimumSide: CGFloat = 16

    static func make(count: Int) -> UIView {
        let label = UILabel()
        label.text = count.formatted()
        label.font = UIFont.preferredFont(forTextStyle: .caption2).bold()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(Palette.onForest)
        label.textAlignment = .center
        label.backgroundColor = UIColor(Palette.forest)
        label.layer.masksToBounds = true
        let size = label.intrinsicContentSize
        let side = max(Self.minimumSide, size.height)
        label.frame = CGRect(x: 0, y: 0, width: max(side, size.width + Self.horizontalInset * 2), height: side)
        label.layer.cornerRadius = side / 2
        return label
    }
}
```

`bold()` — небольшое расширение `UIFont+Bold.swift` (`withSymbolicTraits(.traitBold)`). В `CalendarScreen` словарь собирается так: `Dictionary(grouping: events, by: \.day).mapValues(\.count)`. Карточка календаря получает `.padding(Spacing.small)` вместо `.padding(.horizontal, Spacing.xSmall)`. Спецификация 6.11: «на днях с событиями — капсула Forest с числом событий». Backlog Android: то же.

## 3. Перевод контента

**Почему в маппинге, а не в экранах:** язык не меняется, пока приложение запущено. Если репозиторий сразу кладёт в модель текст на нужном языке, ни один экран не меняется: `task.title` уже переведён, поиск по карте ищет по переведённым названиям. Так же переделывается и `EcoTip`: в модели снова только `title` / `body`, а `EcoTip+Localized` теряет `localizedTitle` / `localizedBody`.

**Схема Firestore** (обратно совместима: старые поля остаются на русском, а для Android — запасной вариант):

| Коллекция | Старые поля (ru) | Новые карты `{ru, be, en}` |
|---|---|---|
| `tasks` | `title`, `description` | `titles`, `descriptions` |
| `events` | `title`, `description`, `location` | `titles`, `descriptions`, `locations` |
| `shopItems` | `title`, `partnerName` | `titles`, `partnerNames` |
| `mapPoints` | `name`, `address` | `names`, `addresses` |
| `surveys` | `question`, `options` | `questions`, `optionLists` (`{ru: [...], be: [...], en: [...]}`) |
| `ecoTips` | `title`, `body` | `titles`, `bodies` (уже есть) |

`data/remote/ContentLanguage.swift` — один выбор языка для слоя данных (повторяет `AppLanguage.currentCode`, который живёт в presentation):

```swift
import Foundation

nonisolated enum ContentLanguage {
    private static let fallbackCode = "ru"

    static var current: String {
        return Bundle.main.preferredLocalizations.first ?? fallbackCode
    }
}
```

`data/remote/DocumentSnapshot+Fields.swift` получает переводимые поля:

```swift
func localizedString(_ field: String, translations: String) -> String? {
    let localized = get(translations) as? [String: String]
    return localized?[ContentLanguage.current] ?? string(field)
}

func localizedStrings(_ field: String, translations: String) -> [String] {
    let localized = get(translations) as? [String: [String]]
    return localized?[ContentLanguage.current] ?? strings(field)
}
```

Маппинг, например в `FirestoreTasksRepository.task(from:)`:

```swift
guard let title = document.localizedString(fieldTitle, translations: fieldTitles),
      let description = document.localizedString(fieldDescription, translations: fieldDescriptions),
```

Так же меняются `FirestoreEventsRepository`, `FirestoreShopRepository` (награды), `FirestoreMapPointsRepository`, `FirestoreFeedbackRepository` (опрос) и `FirestoreEcoTipsRepository`. В домене поля `titles` / `bodies` у `EcoTip` удаляются.

**Города.** `city` в документах — ключ для фильтров и анкеты, он остаётся русским. Для показа нужен перевод: 12 ключей `city_minsk`, `city_brest`, … в `Localizable.xcstrings` и `presentation/components/CityName.swift`:

```swift
enum CityName {
    private static let titles: [String: LocalizedStringResource] = [
        "Минск": .cityMinsk,
        "Брест": .cityBrest,
    ]

    static func title(_ city: String) -> String {
        return titles[city].map { return String(localized: $0) } ?? city
    }
}
```

В словаре все 12 городов. `CityName.title` используется везде, где город показывается: `TaskFiltersSheet`, `TaskRowsCard`, `ProfileSetupScreen`, `ProfileScreen` (`city_and_points`), `MapPointSheet`.

**Сервер.** Страница результата скана купона (`functions/src/shop.ts`, `renderScanPage`) уже знает язык — берёт `titles[language]`, иначе `title`.

Спецификация (раздел 1, «Данные»): переводимые поля, правило «язык выбирается при чтении документа, русские поля — запасной вариант». Backlog Android: чтение `titles` / `descriptions` / …, перевод городов.

## 4. Больше контента (Android-репо `scripts/`)

**Почему отдельные модули:** 30 заданий и 20 статей на трёх языках не уместятся в `seed-firestore.js`. Контент переезжает в `scripts/content/`: `tasks.js`, `events.js`, `shop.js`, `map-points.js`, `surveys.js`, `eco-tips.js` (перенос). Каждый модуль экспортирует массив с фиксированным `id` и картами переводов.

```js
module.exports = [
  {
    id: 'recycle_plastic_minsk',
    titles: { ru: 'Сдай пластик на переработку', be: 'Здай пластык на перапрацоўку', en: 'Recycle plastic' },
    descriptions: { ru: '…', be: '…', en: '…' },
    category: 'RECYCLING',
    city: 'Минск',
    verification: 'QR',
    rewardPoints: 60,
    rewardXp: 60,
    imageUrl: null,
  },
];
```

Общая запись — `upsertByTitle`. Существующий документ находится по русскому названию и перезаписывается на месте, новый создаётся с фиксированным id. Русские поля дублируются из карт:

```js
async function upsertByTitle(collectionName, documents, titleField, toDocument) {
  if (onlyCollections && !onlyCollections.includes(collectionName)) {
    return [];
  }
  const collectionRef = root.collection(collectionName);
  const existing = await collectionRef.get();
  const idByTitle = new Map(existing.docs.map((doc) => [doc.get(titleField), doc.id]));
  const batch = db.batch();
  const written = documents.map(({ id, ...content }) => {
    const document = toDocument(content);
    const docRef = collectionRef.doc(idByTitle.get(document[titleField]) ?? id);
    batch.set(docRef, document);
    return { id: docRef.id, doc: document };
  });
  await batch.commit();
  console.log(`${collectionName}: ${documents.length} documents written`);
  return written;
}
```

`seedQrSecrets` и `seedEventSecrets` создают секрет только при его отсутствии. Иначе повторный seed поменял бы код, и уже распечатанные QR перестали бы работать.

**Объём** (всё на ru/be/en):
- **Задания — 30:** все 12 городов `SupportedCities`, все 5 категорий, все 3 способа подтверждения.
- **Статьи — 20:** +13: 6 статей, 4 видео, 3 детских. Каждое видео проверяется через oEmbed, к каждой статье — обложка Unsplash в `games/covers/`.
- **События — 12:** октябрь 2026 — январь 2027, в нескольких городах. В паре дней по 2–3 события, чтобы было видно число на календаре.
- **Магазин — 15 наград:** партнёры вымышленные, как сейчас.
- **Опросы — 3.** Активен один, `isActive` у остальных — `false`, как в текущей модели.
- **Карта:** добавляются только пункты приёма, найденные в открытых источниках с адресом. Координаты берутся геокодированием адреса через OpenStreetMap Nominatim и проверяются по совпадению улицы и дома. Непроверенные точки не добавляются. Итог по числу точек — в отчёте.

## 5. Пять новых игр

Те же правила, что у текущих: `index.html` + `main.js`, движок `Engine`, мост `GP`, 3 жизни (кроме мемори), очко = 1 балл, `maxPoints: 30`. Тексты вопросов и подсказок — на трёх языках.

| id | Название ru / be / en | Механика | Очко за | Конец |
|---|---|---|---|---|
| `quiz_rush` | Эко-блиц / Эка-бліц / Eco blitz | Карточка вопроса въезжает сбоку, 4 ответа, кольцо таймера 10 с, банк из 40 вопросов | верный ответ | 3 ошибки или таймаута |
| `light_switch` | Выключи свет / Выключы святло / Lights out | Дом в разрезе: в комнатах включаются лампы, телевизоры, краны; тап — выключить, пока не заполнился счётчик расхода | выключенный прибор | прибор горит дольше 4 с → жизнь |
| `bee_garden` | Опылитель / Апыляльнік / Pollinator | Пчела ведётся пальцем, цветы вянут по таймеру, касание цветка — расцветает; облака пестицидов и осы | опылённый цветок | касание облака или осы, увядший цветок → жизнь |
| `bike_lane` | Велодорожка / Веласцежка / Bike lane | Вид сверху, 3 полосы, свайп или тап влево и вправо, машины и лужи, листья | собранный лист | столкновение → жизнь |
| `eco_memory` | Эко-мемори / Эка-мэмары / Eco memory | Пары карточек с переворотом и пружиной, уровни 3×4 → 4×4 → 4×5, 60 с на уровень | найденная пара | время вышло |

Каталог: 5 документов, `order` 6–10.

## 6. Плитки игр в хабе

**Почему:** строка списка с маленькой SF-иконкой выглядит одинаково для всех игр. Большая цветная плитка сразу отличает игры и приглашает нажать. Картинки в бандл не добавляются (правило CLAUDE.md про imagesets): у каждой игры в каталоге есть `iconEmoji` и `iconColors` (два hex-цвета градиента). `sfSymbol` остаётся запасным вариантом.

| id | `iconEmoji` | `iconColors` |
|---|---|---|
| `eco_runner` | 🏃 | `#34C77B`, `#1F6B47` |
| `sort_conveyor` | ♻️ | `#4DA3FF`, `#2E6FD1` |
| `ocean_cleanup` | 🐳 | `#2BB3E8`, `#145F8F` |
| `forest_guard` | 🌲 | `#7ED957`, `#2E8C5E` |
| `eco_merge` | 🌱 | `#C3EE5A`, `#4E9F3D` |
| `quiz_rush` | 🧠 | `#FF9F43`, `#E8590C` |
| `light_switch` | 💡 | `#FFD54F`, `#F08F33` |
| `bee_garden` | 🐝 | `#FFB703`, `#FB8500` |
| `bike_lane` | 🚲 | `#8E7CF0`, `#5B4BC4` |
| `eco_memory` | 🃏 | `#FF6B8A`, `#C9184A` |

Модель `Game` получает `iconEmoji: String?` и `iconColors: [String]`; маппинг — в `FirestoreGamesRepository`. Цвета приходят из данных, это не захардкоженная тема. Разбор hex — в `presentation/games/states/Game+Icon.swift`:

```swift
extension Game {
    private static let hexRadix = 16
    private static let channelMask = 0xFF
    private static let channelMax = 255.0

    var gradientColors: [Color] {
        let colors = iconColors.compactMap(Self.color(hex:))
        return colors.count >= 2 ? colors : [Palette.forest, Palette.forest]
    }

    private static func color(hex: String) -> Color? {
        guard let value = Int(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: hexRadix) else {
            return nil
        }
        return Color(
            red: Double((value >> 16) & channelMask) / channelMax,
            green: Double((value >> 8) & channelMask) / channelMax,
            blue: Double(value & channelMask) / channelMax
        )
    }
}
```

`presentation/games/ui/GameTile.swift` — квадратная плитка с градиентом, крупным эмодзи (`.font(.system(size:))` здесь — рисунок, а не текст, его размер — константа), мягким «дыханием» (`phaseAnimator`). Под плиткой название и рекорд:

```swift
struct GameTile: View {
    private static let emojiScale: CGFloat = 0.46
    private static let breathScale: CGFloat = 1.06
    private static let breathDuration: Double = 1.8

    let game: Game
    let bestScore: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                    .fill(LinearGradient(colors: game.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        Text(game.iconEmoji ?? "🎮")
                            .font(.system(size: proxy.size.width * Self.emojiScale))
                            .phaseAnimator([1, Self.breathScale]) { content, scale in
                                content.scaleEffect(scale)
                            } animation: { _ in
                                return .easeInOut(duration: Self.breathDuration)
                            }
                    }
            }
            .aspectRatio(1, contentMode: .fit)
            Text(game.title)
                .font(.headline)
                .lineLimit(2)
            if let bestScore {
                Text(.gamesBestScoreFormat(bestScore))
                    .font(.footnote)
                    .foregroundStyle(Palette.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
```

Нажатие — `presentation/games/ui/GameTileButtonStyle.swift`: пружинное сжатие до 0.92, лёгкий поворот и `sensoryFeedback(.impact)` при нажатии.

```swift
struct GameTileButtonStyle: ButtonStyle {
    private static let pressedScale: CGFloat = 0.92
    private static let pressedRotation = Angle.degrees(-3)

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? Self.pressedScale : 1)
            .rotationEffect(configuration.isPressed ? Self.pressedRotation : .zero)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, isPressed in
                return isPressed
            }
    }
}
```

`GamesHubScreen` — `LazyVGrid` из двух колонок, `Spacing.small` между плитками. Спецификация 6.17: «хаб — сетка плиток: градиент `iconColors`, `iconEmoji`, название, рекорд». Backlog Android: та же плитка.

---

## Порядок работ

0. Коммит исправлений предупреждений.
1. План → `claude/content-games-plan.ru.md`. Спецификация обеих копий: разделы 1, 6.8, 6.11, 6.15, 6.17, backlog.
2. iOS: тема → календарь → перевод контента (данные, `CityName`) → плитки игр. Сборка после каждого пункта.
3. Android-репо:
   - 5 игр, проверка в Safari симулятора через тестовую страницу в scratchpad;
   - модули контента и `upsertByTitle`;
   - обложки;
   - поиск и проверка точек карты;
   - `shop.ts`.
4. Перед `firebase deploy --only hosting,functions` и `node seed-firestore.js` — спросить подтверждение: это общий прод.
5. Коммиты по формату CLAUDE.md, отдельно в каждом репозитории.

## Проверка

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

Сборка без предупреждений из кода проекта. `node --check` для всех `main.js`, `engine.js` и модулей контента; проверка, что у каждого элемента контента есть все три языка:

```bash
node -e "for (const f of ['tasks','events','shop','map-points','surveys','eco-tips']) { const items = require('./scripts/content/' + f); for (const item of items.ecoTips ?? items) for (const [k, v] of Object.entries(item)) if (v && typeof v === 'object' && 'ru' in v && !('be' in v && 'en' in v)) console.log(f, item.id, k); }"
```

Ручные сценарии (у пользователя на симуляторе, светлая и тёмная тема):
1. Профиль → «Тема»: в меню только текст.
2. Календарь: сетка не касается краёв карточки, на днях с событиями — капсула с числом («2», «3»), выбор дня работает.
3. Язык en / be (Настройки → приложение → Язык): задания, события, награды, точки карты, опрос, статьи и города — на выбранном языке; на ru — как раньше.
4. Игры: хаб — сетка 10 цветных плиток, «дыхание», пружина и отклик при нажатии; каждая игра запускается, жизни и итог работают (дополнительно — тестовая страница в Safari симулятора, без ошибок JS).
5. После seed: без дублей в списках заданий, событий и магазина; ранее выполненные задания остаются выполненными; старые QR заданий и событий принимаются.

## Отклонения при реализации

- `EventCountBadge` — `UILabel` с фиксированным размером через Auto Layout (`customView` в `UICalendarView` берёт размер из ограничений); `UIFont+Bold.swift` — в `presentation/components/`.
- `EcoTip+Localized.swift` переименован в `EcoTip+Reading.swift`: в нём остались `readMinutes`, `preview`, `coverUrl`.
- Город в `TaskCityFilter.title` (чипы фильтров) тоже идёт через `CityName.title`. `MapPointSheet` город не показывает, правки не нужны.
- «Эко-блиц» сделан на DOM-карточках (текст вопросов переносится и масштабируется системой), canvas — только слой частиц.
- Новые задания — только `SELF` и `PHOTO`: QR-задание обещает физическую стойку с кодом, которой нет. QR-заданий по-прежнему 2.
- Каталог игр вынесен в `scripts/content/games.js`; `upsert` принимает функцию ключа (у карты — название + адрес, так как у нескольких пунктов одинаковое название).
- Точки карты: 12 новых из справочника ecoinfo.bas-net.by (НАН Беларуси), у каждой адрес подтверждён геокодированием Nominatim до дома. 6 кандидатов отброшены (Байкальская 58/1, Жилуновича 2А, Голодеда 35, Вострецова 12А, Гомельское ш. 58а, Западная 1 — дом не найден). Гомель, Гродно, Витебск, Могилёв, Бобруйск, Орша, Мозырь, Борисов — без новых точек: в справочнике у них либо только металлолом, либо нет точного адреса. 7 старых демо-точек остались как были, их реальность не проверялась.
- Факты в статьях исправлены: светодиоды тратят в 4–5 раз меньше энергии (не 5–8), органика — около трети бытового мусора (не половина), убрана непроверяемая цифра «батарейка загрязняет 20 м² почвы».
