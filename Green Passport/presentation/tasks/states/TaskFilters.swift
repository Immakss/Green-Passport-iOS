import Foundation

struct TaskFilters: Hashable {
    var status: TaskStatusFilter = .available
    var verifications: Set<TaskVerification> = []
    var city: TaskCityFilter = .profileCity
    var categories: Set<TaskCategory> = []

    var activeCount: Int {
        let statusCount = status == .available ? 0 : 1
        let cityCount = city == .profileCity ? 0 : 1
        return statusCount + cityCount + verifications.count + categories.count
    }

    func apply(
        to tasks: [EcoTask],
        completedIds: Set<String>,
        pendingIds: Set<String>,
        profileCity: String?
    ) -> [EcoTask] {
        return tasks.filter { task in
            return matchesStatus(task, completedIds: completedIds, pendingIds: pendingIds)
                && (verifications.isEmpty || verifications.contains(task.verification))
                && city.matches(task, profileCity: profileCity)
                && (categories.isEmpty || categories.contains(task.category))
        }
    }

    func chips(profileCity: String?) -> [TaskFilterChip] {
        var chips: [TaskFilterChip] = []
        if status != .available {
            var remaining = self
            remaining.status = .available
            chips.append(TaskFilterChip(id: "status", title: String(localized: status.title), remaining: remaining))
        }
        if city != .profileCity {
            var remaining = self
            remaining.city = .profileCity
            chips.append(TaskFilterChip(id: "city", title: city.title(profileCity: profileCity), remaining: remaining))
        }
        for verification in TaskVerification.filterOrder where verifications.contains(verification) {
            var remaining = self
            remaining.verifications.remove(verification)
            chips.append(TaskFilterChip(
                id: "verification-\(verification.rawValue)",
                title: String(localized: verification.title),
                remaining: remaining
            ))
        }
        for category in TaskCategory.allCases where categories.contains(category) {
            var remaining = self
            remaining.categories.remove(category)
            chips.append(TaskFilterChip(
                id: "category-\(category.rawValue)",
                title: String(localized: category.title),
                remaining: remaining
            ))
        }
        return chips
    }

    private func matchesStatus(_ task: EcoTask, completedIds: Set<String>, pendingIds: Set<String>) -> Bool {
        let isCompleted = completedIds.contains(task.id)
        let isPending = pendingIds.contains(task.id)
        switch status {
        case .available:
            return !isCompleted && !isPending
        case .underReview:
            return isPending && !isCompleted
        case .completed:
            return isCompleted
        case .all:
            return true
        }
    }
}
