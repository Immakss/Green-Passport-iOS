final class RankPendingTasksUseCase {
    private static let homeTasksLimit = 3
    private static let cityMatchWeight = 2
    private static let interestMatchWeight = 1

    func execute(tasks: [EcoTask], completedIds: Set<String>, profile: UserProfile?) -> [EcoTask] {
        let pending = tasks.filter { return !completedIds.contains($0.id) }
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
