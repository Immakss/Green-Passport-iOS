final class FetchPendingTasksUseCase {
    private static let homeTasksLimit = 3
    private static let cityMatchWeight = 2
    private static let interestMatchWeight = 1

    private let tasksRepository: TasksRepository

    init(tasksRepository: TasksRepository) {
        self.tasksRepository = tasksRepository
    }

    func execute(userId: String, profile: UserProfile?) async throws -> [EcoTask] {
        let completedIds = try await tasksRepository.fetchCompletedTaskIds(userId: userId)
        let pending = try await tasksRepository.fetchTasks().filter { !completedIds.contains($0.id) }
        let ranked = pending.enumerated().sorted { lhs, rhs in
            let lhsScore = Self.score(lhs.element, profile: profile)
            let rhsScore = Self.score(rhs.element, profile: profile)
            if lhsScore != rhsScore {
                return lhsScore > rhsScore
            }
            return lhs.offset < rhs.offset
        }
        return Array(ranked.map(\.element).prefix(Self.homeTasksLimit))
    }

    private static func score(_ task: EcoTask, profile: UserProfile?) -> Int {
        guard let profile else {
            return 0
        }
        let cityScore = task.city == profile.city ? cityMatchWeight : 0
        let interestScore = profile.interests.contains(task.category) ? interestMatchWeight : 0
        return cityScore + interestScore
    }
}
