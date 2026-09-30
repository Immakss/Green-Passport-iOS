import Foundation

enum TaskFilter: Hashable {
    case forYou
    case all
    case category(TaskCategory)

    static let allFilters: [TaskFilter] = [.forYou, .all] + TaskCategory.allCases.map { return .category($0) }

    var title: String {
        switch self {
        case .forYou:
            return String(localized: .forYou)
        case .all:
            return String(localized: .tasksFilterAll)
        case .category(let category):
            return String(localized: category.title)
        }
    }
}
