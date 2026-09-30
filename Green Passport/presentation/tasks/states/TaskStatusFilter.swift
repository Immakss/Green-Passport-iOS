import Foundation

enum TaskStatusFilter: CaseIterable, Hashable {
    case available
    case underReview
    case completed
    case all

    var title: LocalizedStringResource {
        switch self {
        case .available:
            return .availableTasks
        case .underReview:
            return .underReview
        case .completed:
            return .completedTasks
        case .all:
            return .tasksFilterAll
        }
    }
}
