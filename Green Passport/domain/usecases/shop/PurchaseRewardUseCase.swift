final class PurchaseRewardUseCase {
    private let rewardsRepository: RewardsRepository

    init(rewardsRepository: RewardsRepository) {
        self.rewardsRepository = rewardsRepository
    }

    func execute(reward: Reward) async throws -> Coupon {
        return try await rewardsRepository.redeemReward(rewardId: reward.id)
    }
}
