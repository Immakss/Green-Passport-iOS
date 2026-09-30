import Foundation

enum MapFilter: Hashable {
    case all
    case type(MapPointType)

    static let allFilters: [MapFilter] = [.all] + MapPointType.allCases.map { return .type($0) }

    var title: String {
        switch self {
        case .all:
            return String(localized: .mapFilterAll)
        case .type(let type):
            return String(localized: type.title)
        }
    }
}
