# План: фокус карты на геолокации, иначе на городе из профиля


## Контекст
Карта сейчас открывается «в случайном месте». `MapScreen.initialPosition(for:)` центрирует камеру по средней точке всех меток. Метки разбросаны по 12 городам, поэтому середина попадает куда-то между ними. Геолокации в приложении нет совсем: нет `NSLocationWhenInUseUsageDescription` и нет кода CoreLocation. К тому же после перехода на живые слушатели `onChange(of: points)` двигает камеру на каждом снапшоте: сначала из кеша, потом с сервера.

Нужное поведение:
- разрешение дано — камера на пользователе;
- отказано или координаты не пришли — на городе из профиля;
- города нет (гость) — на Минске.

Камера ставится один раз при открытии и больше сама не прыгает.

## 1. Спека (6.12 Карта)
Строку «Камера центрируется по средней точке всех меток» заменить на:
- При открытии карты запрашивается разрешение на геолокацию (только «при использовании»).
- Разрешено: камера на пользователе, видна его точка и кнопка «моё местоположение».
- Запрещено или нет координат за 5 с: камера на городе из анкеты, без анкеты — на Минске.
- Камера ставится один раз и не сбрасывается при обновлении меток.

В «Android backlog» добавить: «Карта: фокус на геолокации, иначе на городе из анкеты (6.12)».

## 2. Разрешение
- `project.pbxproj`, обе конфигурации: `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "The map is centered on your location to show the nearest eco points.";`
- `Resources/InfoPlist.xcstrings`, ключ `NSLocationWhenInUseUsageDescription`:
  - ru: «Карта показывает ближайшие эко-точки рядом с вами»;
  - be: «Карта паказвае бліжэйшыя эка-пункты побач з вамі»;
  - en: «The map shows the eco points nearest to you».

## 3. Domain
`domain/models/GeoPoint.swift`:
```swift
nonisolated struct GeoPoint: Hashable, Sendable {
    let latitude: Double
    let longitude: Double
}
```
`domain/models/MapFocus.swift`:
```swift
nonisolated enum MapFocus: Hashable, Sendable {
    case userLocation(GeoPoint)
    case city(GeoPoint)
}
```
`SupportedCities` получает таблицу центров и город по умолчанию:
```swift
static let defaultCity = "Минск"
static let centers: [String: GeoPoint] = [
    "Минск": GeoPoint(latitude: 53.9006, longitude: 27.5590),
    "Брест": GeoPoint(latitude: 52.0976, longitude: 23.7341),
    "Витебск": GeoPoint(latitude: 55.1904, longitude: 30.2049),
    "Гомель": GeoPoint(latitude: 52.4345, longitude: 30.9754),
    "Гродно": GeoPoint(latitude: 53.6884, longitude: 23.8258),
    "Могилёв": GeoPoint(latitude: 53.9007, longitude: 30.3314),
    "Бобруйск": GeoPoint(latitude: 53.1384, longitude: 29.2214),
    "Барановичи": GeoPoint(latitude: 53.1327, longitude: 26.0139),
    "Борисов": GeoPoint(latitude: 54.2279, longitude: 28.5050),
    "Пинск": GeoPoint(latitude: 52.1229, longitude: 26.0951),
    "Орша": GeoPoint(latitude: 54.5081, longitude: 30.4172),
    "Мозырь": GeoPoint(latitude: 52.0495, longitude: 29.2456),
]
```
`domain/repositories/LocationRepository.swift`:
```swift
protocol LocationRepository {
    func currentLocation() async -> GeoPoint?
}
```
`domain/usecases/map/ResolveMapFocusUseCase.swift` — сначала геолокация, иначе город из профиля, иначе Минск:
```swift
final class ResolveMapFocusUseCase {
    private let locationRepository: LocationRepository
    private let authRepository: AuthRepository
    private let userProfileRepository: UserProfileRepository

    func execute() async -> MapFocus {
        if let location = await locationRepository.currentLocation() {
            return .userLocation(location)
        }
        let city = await profileCity() ?? SupportedCities.defaultCity
        let center = SupportedCities.centers[city] ?? SupportedCities.centers[SupportedCities.defaultCity]
        return .city(center ?? GeoPoint(latitude: 0, longitude: 0))
    }
}
```
`profileCity()` берёт сессию из `observeSession().first` и делает `try? await userProfileRepository.observeProfile(userId:).firstValue()`. Это кеш-first, поэтому быстро. При реализации заменить `0, 0` на force-неопциональный центр Минска через отдельную константу `defaultCenter`.

## 4. Data
`data/local/CoreLocationRepository.swift` на современном API без делегата:
```swift
final class CoreLocationRepository: LocationRepository {
    private static let timeout = Duration.seconds(5)

    func currentLocation() async -> GeoPoint? {
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }
        return await withTaskGroup(of: GeoPoint?.self) { group in
            group.addTask {
                do {
                    for try await update in CLLocationUpdate.liveUpdates() {
                        if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                            return nil
                        }
                        if let location = update.location {
                            return GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        }
                    }
                } catch {
                    return nil
                }
                return nil
            }
            group.addTask {
                try? await Task.sleep(for: Self.timeout)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
    }
}
```
`CLServiceSession` сам показывает системный запрос при первом открытии карты, поэтому правило «разрешения — при первом использовании» соблюдается. Отказ даёт `nil`, и тогда срабатывает город из профиля. В DI добавить `private lazy var locationRepository: LocationRepository = CoreLocationRepository()` и передать use case в `buildMapViewModel()`.

## 5. Presentation
- `MapUiState`: `var focus: MapFocus?`.
- `MapViewModel.observe()`: в `withTaskGroup` параллельно слушает метки (как сейчас) и один раз вычисляет фокус: `uiState.focus = await resolveMapFocus.execute()`. При `retry()` фокус не пересчитывается (guard `focus == nil`).
- `MapScreen`:
  - удалить `initialPosition(for:)` и `.onChange(of: uiState.points)`;
  - `.onChange(of: uiState.focus) { _, focus in position = Self.position(for: focus) }`, срабатывает один раз;
  - для `.userLocation` камера `.userLocation(fallback: .region(…))`, для `.city` — `.region` с текущим `initialSpan`;
  - в контент карты добавить `UserAnnotation()`, в `mapControls` — `MapUserLocationButton()`.
  - Перевод `GeoPoint` → `CLLocationCoordinate2D` делается расширением `GeoPoint+Coordinate.swift` в `presentation/map/states` (по образцу `MapPoint+Coordinate.swift`).

## 6. Документация
В `CLAUDE.md`, раздел «Local data & notifications», дописать: геолокация «при использовании» запрашивается при первом открытии карты (`CoreLocationRepository`), камера стоит на пользователе, иначе на городе из анкеты, иначе на Минске.

## Проверка
```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'generic/platform=iOS Simulator' build
```
Сценарии на устройстве или симуляторе (в симуляторе Features → Location → Custom Location):
1. Первое открытие карты → системный запрос. «Разрешить» → камера на пользователе, видна синяя точка, кнопка «моё местоположение» работает.
2. «Не разрешать» → камера на городе из анкеты (например, Гродно).
3. Гость без анкеты и с отказом → камера на Минске.
4. Пока карта открыта, метки обновляются (кеш → сервер), а камера не прыгает. Ручной сдвиг карты тоже не сбрасывается.
5. Отказ в Настройках → Конфиденциальность → снова открыть карту → город из анкеты, без зависаний (таймаут 5 с).
