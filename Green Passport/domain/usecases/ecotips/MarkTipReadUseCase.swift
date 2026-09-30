final class MarkTipReadUseCase {
    private let rewardsRepository: RewardsRepository

    init(rewardsRepository: RewardsRepository) {
        self.rewardsRepository = rewardsRepository
    }

    func execute(tipId: String) async throws -> RewardResult {
        return try await rewardsRepository.recordTipRead(tipId: tipId)
    }
}
