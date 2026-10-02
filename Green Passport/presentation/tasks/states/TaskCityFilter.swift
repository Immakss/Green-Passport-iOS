import Foundation

enum TaskCityFilter: Hashable {
    case profileCity
    case all
    case city(String)

    func title(profileCity: String?) -> String {
        switch self {
        case .profileCity:
            return profileCity.map { return CityName.title($0) } ?? String(localized: .myCity)
        case .all:
            return String(localized: .allCities)
        case .city(let name):
            return CityName.title(name)
        }
    }

    func matches(_ task: EcoTask, profileCity: String?) -> Bool {
        switch self {
        case .profileCity:
            guard let profileCity, !profileCity.isEmpty else {
                return true
            }
            return task.city == profileCity
        case .all:
            return true
        case .city(let name):
            return task.city == name
        }
    }
}
