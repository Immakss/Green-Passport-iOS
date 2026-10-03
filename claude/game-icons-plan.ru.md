# План: уникальные PNG-иконки игр и ровная сетка хаба

После одобрения план копируется в `claude/game-icons-plan.ru.md` первым действием. Изменение UX сначала вносится в `claude/ux-spec.ru.md` (обе копии), отличие для Android — в «Android backlog».

## Контекст

Пользователь открыл хаб игр и увидел две проблемы:
1. **У всех игр одна иконка.** Причина: seed ещё не запускался, в каталоге Firestore нет `iconEmoji` / `iconColors`, и каждая плитка падает в запасной 🎮 на градиенте Forest. Но и с эмодзи иконки были бы «системными». Решение: своя PNG-иллюстрация на каждую игру.
2. **Верхний ряд стоит неровно.** `LazyVGrid` по умолчанию центрирует ячейки по вертикали внутри строки. Название в две строки («Сортировочный конвейер») делает ячейку выше, и соседняя плитка с названием в одну строку съезжает вниз относительно неё.

**Решения пользователя:**
- **Где лежат PNG:** рядом с игрой на Hosting, `games/<id>/icon.png`. В каталоге — поле `iconPath`. Новая игра по-прежнему добавляется папкой и документом, без релиза приложения, а Android получает те же картинки.
- **Стиль:** плоские иллюстрации-сценки игры на градиенте игры, в части иконок — маскот приложения.
- **Без эмодзи Apple:** их графику нельзя распространять в своих картинках, тем более для Android. Иллюстрации рисуются векторными фигурами, маскот — свой арт (`games/common/mascot.png`).

---

## 1. Ровная сетка

**Почему:** плитки должны начинаться на одной линии, а подписи — занимать одинаковую высоту.
- `GridItem(alignment: .top)` прижимает содержимое ячеек к верху строки.
- `lineLimit(2, reservesSpace: true)` резервирует под название две строки даже для короткого, поэтому строка рекорда тоже стоит на одной высоте.

`presentation/games/ui/GamesHubScreen.swift`:

```swift
LazyVGrid(
    columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.medium, alignment: .top), count: Self.columnCount),
    alignment: .leading,
    spacing: Spacing.large
) {
```

`presentation/games/ui/GameTile.swift`:

```swift
Text(game.title)
    .font(.headline)
    .foregroundStyle(Color.primary)
    .lineLimit(Self.titleLineLimit, reservesSpace: true)
```

## 2. Иконка из каталога

**Почему URL в модели:** адрес иконки строится так же, как адрес игры: база `GamesBaseURL` из Info.plist + путь из каталога. Эта логика уже живёт в `FirestoreGamesRepository`. Если репозиторий сразу кладёт в `Game` готовый `iconUrl`, плитке не нужно ничего знать о базе.

`domain/models/Game.swift`:

```swift
import Foundation

nonisolated struct Game: Identifiable, Hashable, Sendable {
    let id: String
    let titles: [String: String]
    let path: String
    let sfSymbol: String
    var iconUrl: URL?
    var iconEmoji: String?
    var iconColors: [String] = []
    let maxPoints: Int
    let order: Int
}
```

`data/remote/FirestoreGamesRepository.swift` — поле `iconPath` и общий построитель адреса, который переиспользует и `url(for:language:theme:)`:

```swift
private static let fieldIconPath = "iconPath"

iconUrl: document.string(Self.fieldIconPath).flatMap { return Self.hostedUrl(path: $0) },

private static func hostedUrl(path: String) -> URL? {
    guard let base = Bundle.main.object(forInfoDictionaryKey: baseUrlInfoKey) as? String,
          let baseUrl = URL(string: base) else {
        return nil
    }
    return baseUrl.appending(path: path)
}
```

`url(for:language:theme:)` начинается с `Self.hostedUrl(path: game.path)` вместо повторного чтения Info.plist.

## 3. Плитка с картинкой

**Почему с запасным вариантом:** картинка грузится по сети. Пока она грузится, при ошибке или у игры без `iconPath` плитка показывает прежний градиент с эмодзи. `AsyncImage` идёт через общий `URLCache`, поэтому после первой загрузки картинка показывается из кеша сразу. «Дыхание» остаётся только у эмодзи: картинка — готовая композиция, а живость ей даёт пружина при нажатии.

`presentation/games/ui/GameTile.swift` — квадрат плитки:

```swift
private var artwork: some View {
    return RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
        .fill(LinearGradient(colors: game.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            AsyncImage(url: game.iconUrl) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    emojiFallback
                }
            }
        }
        .clipShape(.rect(cornerRadius: CornerRadius.large, style: .continuous))
        .accessibilityHidden(true)
}
```

`emojiFallback` — текущий `GeometryReader` с эмодзи и `phaseAnimator`, без изменений.

## 4. Иллюстрации (Android-репо)

**Почему генератор, а не ручная отрисовка:**
- Скрипт можно перезапустить, если поменяются цвета или добавится игра.
- Все иконки получают один стиль: тот же градиент, мягкие тени, толщина обводки.

`scripts/game-icons.py` (Pillow) рисует каждую иконку в 2048×2048 и уменьшает до 512×512 с `LANCZOS` для гладких краёв. Результат пишется в `games/<id>/icon.png`. Общий каркас:

```python
SIZE = 2048
OUTPUT = 512

def canvas(colors):
    image = Image.new('RGBA', (SIZE, SIZE))
    gradient = diagonal_gradient(colors[0], colors[1])
    image.paste(gradient)
    return image, ImageDraw.Draw(image)

def save(image, game_id):
    image.resize((OUTPUT, OUTPUT), Image.LANCZOS).save(GAMES / game_id / 'icon.png', optimize=True)
```

Сцены (фон — градиент `iconColors` игры):

| id | Сцена |
|---|---|
| `eco_runner` | маскот в прыжке над мешком мусора, сзади холмы и листья |
| `sort_conveyor` | лента конвейера с бутылкой и четыре цветных бака (стекло, металл, бумага, пластик) |
| `ocean_cleanup` | волны, лодка, сеть с бутылкой |
| `forest_guard` | ёлки, у одной искра, сверху капля воды |
| `eco_merge` | плитки 2×2: семя, росток, куст, дерево |
| `quiz_rush` | облачко «?» и кольцо таймера, маскот выглядывает снизу |
| `light_switch` | домик в разрезе: одно окно светится, лампочка |
| `bee_garden` | пчела с траекторией полёта и два цветка |
| `bike_lane` | дорога с разметкой сверху, велосипед и листья |
| `eco_memory` | три карточки веером: рубашка с листом и две открытые |

Маскот вставляется из `games/common/mascot.png` (свой арт приложения) в `eco_runner` и `quiz_rush`. Размер файла — около 60–120 КБ: PNG с прозрачностью не нужен, фон сплошной. Если файл больше 150 КБ, иконка сохраняется в палитру из 256 цветов (`quantize`).

Каталог `scripts/content/games.js`: у каждой игры `iconPath: '<id>/icon.png'`. `iconEmoji` / `iconColors` остаются запасным вариантом и источником цветов фона. Hosting уже отдаёт `*.png` с `Cache-Control: max-age=604800`.

## 5. Спецификация и документация

- `claude/ux-spec.ru.md` 6.17, «Плитка игры»: картинка `iconPath` (PNG 512×512 на Hosting рядом с игрой, сцена игры на её градиенте). Пока не загрузилась или её нет — градиент с `iconEmoji`. Название всегда занимает место двух строк, плитки в ряду выровнены по верху.
- Backlog Android: картинка из `iconPath` (Coil) с тем же запасным вариантом, выравнивание сетки.
- Android `CLAUDE.md` (раздел про игры): поле `iconPath`, генератор `scripts/game-icons.py`.

---

## Порядок работ

1. План → `claude/game-icons-plan.ru.md`, спецификация в обоих репозиториях.
2. iOS: сетка → модель и репозиторий → плитка, сборка.
3. Android-репо: генератор, 10 иконок, просмотр контактного листа всех иконок до коммита, `iconPath` в каталоге, CLAUDE.md.
4. Коммиты в обоих репозиториях. Deploy и seed пользователь запускает сам, как в прошлый раз: `firebase deploy --only hosting`, затем `node seed-firestore.js --only=games`.

## Проверка

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

Сборка без предупреждений из кода проекта. Иконки: `python3 scripts/game-icons.py`, затем просмотр контактного листа 10 иконок (каждая узнаётся, стиль общий, ничего не обрезано по краям при скруглении плитки).

Ручные сценарии (у пользователя на симуляторе):
1. До deploy и seed: плитки — градиент с эмодзи, верхние края в каждом ряду на одной линии, «Сортировочный конвейер» в две строки не сдвигает соседа.
2. После `firebase deploy --only hosting` и `node seed-firestore.js --only=games`: в хабе 10 разных иллюстраций; в режиме полёта после первого показа они берутся из кеша, у не загруженных — градиент с эмодзи.
3. Светлая и тёмная тема: иконки читаются на обоих фонах.
