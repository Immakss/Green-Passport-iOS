# Приложение под админку: архив, новые ошибки, картинка акции

Этап 8 плана админки (`greenpassport-admin/claude/admin-panel-plan.ru.md`, §4). Android уже сделан (`green-passport-android/claude/admin-apps-plan.ru.md`). Спецификация `claude/ux-spec.ru.md` обновлена и совпадает с Android: раздел 1 «Архив из админки», 6.6, 6.7, 6.10, 6.20.

---

## 1. Архив скрывается из каталогов, но не из ссылок

### Почему

Админка архивирует контент (`isActive: false`), а приложение этого поля не читает, и архивное остаётся в списках. Фильтровать в репозиториях нельзя: `FirestoreHistoryRepository` и `ObserveCouponsUseCase` берут из полных списков названия заданий, событий и акций. Шторка события, шторка совета и модерация ищут документ по id через те же `ObserveEventsUseCase`, `ObserveEcoTipsUseCase` и `ObserveTasksUseCase`.

Поэтому модели получают флаг, а use case каталога фильтрует. Справочным экранам контейнер собирает тот же use case с `includesArchived: true`, и сигнатуры ViewModel не меняются.

### Код

```swift
nonisolated struct EcoTask: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let category: TaskCategory
    let city: String
    let rewardPoints: Int
    let rewardXp: Int
    let imageUrl: String?
    let verification: TaskVerification
    var isActive = true
}
```

`var` со значением по умолчанию даёт memberwise-инициализатору параметр по умолчанию. Превью и заглушки не меняются, а мапперы передают значение явно (`document.bool(fieldIsActive) ?? true`).

```swift
final class ObserveTasksUseCase {
    private let tasksRepository: TasksRepository
    private let includesArchived: Bool

    init(tasksRepository: TasksRepository, includesArchived: Bool = false) {
        self.tasksRepository = tasksRepository
        self.includesArchived = includesArchived
    }

    func execute() -> AsyncThrowingStream<[EcoTask], Error> {
        let includesArchived = includesArchived
        return StreamCombiner.mapped(tasksRepository.observeTasks()) { tasks in
            return includesArchived ? tasks : tasks.filter { return $0.isActive }
        }
    }
}
```

```swift
observeTasks: ObserveTasksUseCase(tasksRepository: tasksRepository, includesArchived: true),
```

Без архива: список заданий, главная (задания и ближайшее событие), «Избранное» (задания и советы), календарь, список советов, карта, каталог магазина. С архивом: модерация, шторка события, шторка совета.

---

## 2. Новые ошибки сервера

### Почему

`FunctionsErrorMapper` смотрит только на код. Лимит QR (`resource-exhausted`) показался бы как дневной лимит, окно QR (`failed-precondition`) — как «нужен другой способ подтверждения», а `ShopViewModel` на любую ошибку покупки пишет «недостаточно баллов».

### Код

```swift
nonisolated enum RewardFailure: Hashable, Sendable {
    case dailyLimitReached
    case alreadyCompleted
    case invalidCode
    case notEnoughPoints
    case wrongVerification
    case qrCodeNotActive
    case qrCodeLimitReached
    case rewardSoldOut
    case network
    case unknown
}
```

```swift
private static let serverMessageFailures: [(marker: String, failure: RewardFailure)] = [
    (marker: "qr_not_active", failure: .qrCodeNotActive),
    (marker: "qr_limit_reached", failure: .qrCodeLimitReached),
    (marker: "reward_sold_out", failure: .rewardSoldOut),
]
```

Ключи в `Localizable.xcstrings` (ru / be / en, тексты как на Android): `qr_code_not_active_msg`, `qr_code_limit_reached_msg`, `reward_sold_out`.

```swift
var purchaseMessage: LocalizedStringResource {
    switch self {
    case .notEnoughPoints:
        return .shopInsufficientPoints
    case .rewardSoldOut:
        return .rewardSoldOut
    case .network:
        return .noInternetConnection
    default:
        return .somethingWentWrongMsg
    }
}
```

---

## 3. Картинка акции

### Почему

Админка загружает `imageUrl` акции, а строка каталога её не показывает. Без картинки строка остаётся как сейчас.

### Код

```swift
if let imageUrl = reward.imageUrl {
    RemoteImage(url: URL(string: imageUrl))
        .frame(width: Self.rewardThumbnailSize, height: Self.rewardThumbnailSize)
        .clipShape(.rect(cornerRadius: CornerRadius.medium, style: .continuous))
}
```

---

## Проверка

```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Simulator' build
```

Сценарии на симуляторе — те же, что на Android:
1. Заархивированное задание пропадает из списка, с главной и из избранного, но остаётся в истории и в модерации.
2. Купон архивной акции в «Моих купонах» остаётся с названием.
3. QR-задание вне окна — `qr_code_not_active_msg`, после лимита — `qr_code_limit_reached_msg` (сканер работает только на устройстве).
4. Обмен в закончившейся акции — `reward_sold_out`.
5. Акция с картинкой показывает миниатюру в каталоге.
