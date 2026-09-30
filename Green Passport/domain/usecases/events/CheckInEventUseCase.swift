final class CheckInEventUseCase {
    private let rewardsRepository: RewardsRepository

    init(rewardsRepository: RewardsRepository) {
        self.rewardsRepository = rewardsRepository
    }

    func execute(code: String) async throws -> RewardResult {
        return try await rewardsRepository.checkInEvent(code: code)
    }
}
