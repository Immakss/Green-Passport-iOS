import Foundation

enum CityName {
    private static let titles: [String: LocalizedStringResource] = [
        "Минск": .cityMinsk,
        "Брест": .cityBrest,
        "Витебск": .cityVitebsk,
        "Гомель": .cityGomel,
        "Гродно": .cityGrodno,
        "Могилёв": .cityMogilev,
        "Бобруйск": .cityBobruisk,
        "Барановичи": .cityBaranovichi,
        "Борисов": .cityBorisov,
        "Пинск": .cityPinsk,
        "Орша": .cityOrsha,
        "Мозырь": .cityMozyr,
    ]

    static func title(_ city: String) -> String {
        return titles[city].map { return String(localized: $0) } ?? city
    }
}
