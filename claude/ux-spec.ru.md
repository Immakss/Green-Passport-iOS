# Green Passport — единая UX-спецификация (Android + iOS)

Это единственный источник правды по UX для обеих платформ. Копия лежит в `claude/` обоих репозиториев и должна совпадать.

Порядок работы:
1. Любое изменение UX сначала вносится сюда.
2. Потом оно переносится в код обеих платформ.

Расхождение между платформами, которое здесь не записано, считается багом.

**Паритет означает одинаковые сценарии, а не одинаковые пиксели.** Контролы на каждой платформе родные: HIG на iOS, Material 3 на Android. Общими должны быть:
- структура экранов и точки входа;
- порядок шагов;
- тексты (ключи строк);
- цвета, правила и состояния.

---

## 1. Общие принципы

- **Минимализм плюс цвет.** Фон экранов нейтральный: белый или системный сгруппированный на iOS, белый на Android. Цвет несут только акценты:
  - Forest — действия и выбор;
  - Lime — очки;
  - цвета разделов — плитки иконок;
  - одна крупная цветная карточка прогресса.
- **Заголовок экрана — часть страницы.** На iOS это large title, на Android — `ScreenHeader`. При скролле он уходит вместе с контентом.
- **Детали задания, события и точки на карте** открываются шторкой снизу: sheet с detents на iOS, `GpSheetScaffold` на Android. Это не отдельная страница.
- **Каждый экран с данными** имеет три состояния: загрузка, пусто (маскот и текст), ошибка (маскот, текст и кнопка «Повторить»).
- **Шрифт:** системный (SF на iOS, Roboto на Android), размеры по системной шкале.

## 2. Навигация

### Стартовый поток
Онбординг → Вход/регистрация → Анкета (4 шага) → Главная.
- Гость (анонимный вход) пропускает анкету.
- Анкета показывается любому не-гостю, у которого в `users/{uid}` нет `profileCompletedAt`.

### Вкладки (в этом порядке)
| Вкладка | Ключ строки | iOS SF Symbol | Android Material icon |
|---|---|---|---|
| Главная | `home` | `house` / `house.fill` | `Home` |
| Магазин | `shop` | `bag` / `bag.fill` | `ShoppingCart` |
| Карта | `map` | `map` / `map.fill` | `Map` |
| Избранное | `favorites` | `heart` / `heart.fill` | `Favorite` |

- Профиль открывается по аватару в шапке главной.
- Остальные разделы открываются с главной (быстрые действия) или из профиля (меню).

## 3. Токены цвета

Имена совпадают на обеих платформах: на iOS это color sets в `Assets.xcassets`, на Android — константы в `theme/Color.kt`.

| Токен | Светлая | Тёмная | Где используется |
|---|---|---|---|
| `Forest` (accent / primary) | `#1F6B47` | `#2E8C5E` | кнопки, выбранные элементы, фон карточки прогресса |
| `OnForest` | `#FFFFFF` | `#FFFFFF` | текст на Forest |
| `Lime` (secondary) | `#C3EE5A` | `#B5E04C` | бейдж очков, полоса XP |
| `OnLime` | `#17331F` | `#17331F` | текст на Lime |
| `MintSurface` | `#E6F5EC` | `#1E2A24` | мягкие подложки: совет дня, открытые карточки коллекции |
| `SectionCommunity` | `#34C77B` | `#2FB46F` | сообщество, пункты переработки |
| `SectionGames` | `#8E7CF0` | `#7F6EE0` | игры, эко-магазины, коллекция |
| `SectionTips` | `#FF9F43` | `#F08F33` | советы, достижения |
| `SectionCalendar` | `#4DA3FF` | `#3F93EE` | календарь, группы, история |
| `SectionFeedback` | `#FF6B8A` | `#EE5C7B` | отзывы, избранное (сердце), уведомления |

Цвета аватаров (`AvatarStyle`):
- LIME → `Lime`
- FOREST → `Forest`
- SKY → `SectionCalendar`
- SUNSET → `SectionTips`
- BERRY → `SectionFeedback`
- VIOLET → `SectionGames`

## 4. Общие компоненты

| Компонент | Что показывает | iOS | Android |
|---|---|---|---|
| Бейдж очков | капсула Lime, молния и «+N» | `PointsBadge` | `PointsChip` |
| Плитка иконки | цветной фон разделов и белый символ | `SymbolTile` (скруглённый квадрат, как в «Настройках») | `IconCircle` → **перейти на скруглённый квадрат** (см. backlog) |
| Карточка прогресса | фон Forest; «Уровень N» или «Ваш баланс»; очки; полоса XP Lime; «xp/1000»; маскот с репликой «X XP до уровня N+1» | `ProgressHeroCard` | `ProgressHeroCard` |
| Аватар | круг цвета `AvatarStyle` с маскотом (78%) | `ProfileAvatar` | `ProfileAvatar` |
| Фото-карточка | фото, затемняющий градиент, белые заголовок и подзаголовок | `HeroImageCard` | `HeroImageCard` |
| Фильтры | горизонтальный ряд капсул, выбранная залита Forest | `FilterBar` | `GpFilterChip` |
| Состояния | загрузка, пусто, ошибка с маскотом | `StateView` | `UiStateContent` |

## 5. Иконки: SF Symbol ↔ Material

| Смысл | SF Symbol | Material |
|---|---|---|
| Сообщество | `person.3.fill` | `Groups` |
| Форум | `bubble.left.and.bubble.right.fill` | `Forum` |
| Игры | `gamecontroller.fill` | `SportsEsports` |
| Советы / эко | `leaf.fill` | `Eco` |
| Календарь | `calendar` | `CalendarMonth` |
| Событие | `calendar.badge.clock` | `Event` |
| Отзывы | `text.bubble.fill` | `RateReview` |
| Очки | `bolt.fill` | `Bolt` |
| Уровень / звезда | `star.fill` / `star` | `Star` / `StarBorder` |
| Избранное | `heart` / `heart.fill` | `FavoriteBorder` / `Favorite` |
| Закладка | `bookmark` / `bookmark.fill` | `BookmarkBorder` / `Bookmark` |
| Выполнено | `checkmark.circle.fill` | `CheckCircle` / `TaskAlt` |
| Эко-магазин | `storefront.fill` | `Storefront` |
| Пункт переработки | `arrow.3.trianglepath` | `Recycling` |
| Место | `mappin.and.ellipse` | `Place` |
| Поиск | `magnifyingglass` | `Search` |
| Достижения | `trophy.fill` | `EmojiEvents` |
| Закрыто | `lock.fill` | `Lock` |
| История | `clock.arrow.circlepath` | `History` |
| Покупка награды | `gift.fill` | `CardGiftcard` |
| Уведомления | `bell.fill` | `Notifications` |
| Коллекция карточек | `rectangle.stack.fill` | `Style` |
| Обмен | `arrow.left.arrow.right` | `SwapHoriz` |
| Модерация | `checkmark.shield.fill` | `Shield` |
| Язык | `character.bubble.fill` | `Translate` |
| Редактировать профиль | `pencil` | `Edit` |
| Жалоба | `flag` | `Flag` |
| Выход | `rectangle.portrait.and.arrow.right` | `Logout` |
| Показать / скрыть пароль | `eye` / `eye.slash` | `Visibility` / `VisibilityOff` |
| Игра «Память» | `puzzlepiece.extension.fill` | `Extension` |
| Игра «Сортировка» | `trash.fill` | `DeleteSweep` |
| Игра «Лабиринт» | `safari.fill` | `Explore` |
| Игра «Викторина» | `questionmark.bubble.fill` | `Quiz` |
| QR-сканер | `qrcode.viewfinder` | — (системный UI ML Kit) |
| Фото | `camera.fill` | — (системный пикер) |

## 6. Экраны

Разделы экранов добавляются по мере переноса на iOS. На каждый экран описываются: откуда открывается, блоки сверху вниз, состояния, действия.

_(заполняется по этапам — см. `claude/ios-port-plan.ru.md`)_

## 7. Сознательные различия платформ

| Что | iOS | Android | Почему |
|---|---|---|---|
| Выбор языка | «Профиль → Язык» открывает системные настройки приложения | «Профиль → Язык» — выпадающий список | На iOS язык приложения по HIG меняется в системных настройках |
| Сканер QR | VisionKit `DataScannerViewController` | ML Kit `GmsBarcodeScanning` | Родные сканеры платформ |
| Карта | Apple MapKit | Yandex MapKit | На iOS нативная карта без ключа |

## 8. Android backlog

Что Android должен перенять на редизайне, чтобы догнать iOS:

- [ ] **Sign in with Apple** на экране входа (Firebase `OAuthProvider("apple.com")`).
- [ ] **Цветовая схема.**
  - Нейтральные фоны (белый / `#121815`) вместо мятной заливки карточек.
  - Плитки иконок — скруглённый квадрат вместо круга.
  - Строки списков сгруппированы в секции.
- [ ] **Email, телефон поддержки и `mediaUrl` совета** — кликабельные (`mailto:`, `tel:`, браузер).
- [ ] **PHOTO-задания:** выбор «Снять фото / Из галереи» (сейчас только галерея).
- [ ] **Покупка награды** — диалог подтверждения перед списанием очков.
- [ ] **Лабиринт:** управление свайпами в дополнение к кнопкам-стрелкам.
