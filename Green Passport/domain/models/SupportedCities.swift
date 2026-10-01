nonisolated enum SupportedCities {
    static let all = [
        "Минск",
        "Брест",
        "Витебск",
        "Гомель",
        "Гродно",
        "Могилёв",
        "Бобруйск",
        "Барановичи",
        "Борисов",
        "Пинск",
        "Орша",
        "Мозырь",
    ]

    static let defaultCenter = GeoPoint(latitude: 53.9006, longitude: 27.5590)

    static let centers: [String: GeoPoint] = [
        "Минск": defaultCenter,
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

    static func center(of city: String?) -> GeoPoint {
        return city.flatMap { return centers[$0] } ?? defaultCenter
    }
}
