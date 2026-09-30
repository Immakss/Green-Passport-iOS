struct TasksListUiState {
    var tasks: [EcoTask] = []
    var completedTaskIds: Set<String> = []
    var favoriteTaskIds: Set<String> = []
    var pendingTaskIds: Set<String> = []
    var profile: UserProfile?
    var filter: TaskFilter = .forYou
    var isLoading = true
    var hasError = false

    var availableFilters: [TaskFilter] {
        return profile == nil ? TaskFilter.allFilters.filter { return $0 != .forYou } : TaskFilter.allFilters
    }

    var effectiveFilter: TaskFilter {
        return filter == .forYou && profile == nil ? .all : filter
    }

    var visibleTasks: [EcoTask] {
        switch effectiveFilter {
        case .all:
            return tasks
        case .category(let category):
            return tasks.filter { return $0.category == category }
        case .forYou:
            guard let profile else {
                return tasks
            }
            let matching = tasks.filter { return $0.city == profile.city || profile.interests.contains($0.category) }
            let bestMatches = matching.filter { return $0.city == profile.city && profile.interests.contains($0.category) }
            let otherMatches = matching.filter { return !($0.city == profile.city && profile.interests.contains($0.category)) }
            return bestMatches + otherMatches
        }
    }
}
