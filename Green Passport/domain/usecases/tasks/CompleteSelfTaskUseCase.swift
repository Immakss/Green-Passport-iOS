final class CompleteSelfTaskUseCase {
    private let rewardsRepository: RewardsRepository

    init(rewardsRepository: RewardsRepository) {
        self.rewardsRepository = rewardsRepository
    }

    func execute(taskId: String) async throws -> RewardResult {
        return try await rewardsRepository.completeSelfTask(taskId: taskId)
    }
}
