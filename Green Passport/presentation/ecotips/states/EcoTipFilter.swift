import Foundation

enum EcoTipFilter: Hashable {
    case all
    case category(EcoTipCategory)

    static let allFilters: [EcoTipFilter] = [.all] + EcoTipCategory.allCases.map { return .category($0) }

    var title: String {
        switch self {
        case .all:
            return String(localized: .ecotipsFilterAll)
        case .category(let category):
            return String(localized: category.title)
        }
    }
}
