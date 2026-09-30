final class PurchaseRewardUseCase {
    private let rewardsRepository: RewardsRepository
    private let reminderScheduler: ReminderScheduler

    init(rewardsRepository: RewardsRepository, reminderScheduler: ReminderScheduler) {
        self.rewardsRepository = rewardsRepository
        self.reminderScheduler = reminderScheduler
    }

    func execute(reward: Reward) async throws -> CouponItem {
        let coupon = try await rewardsRepository.redeemReward(rewardId: reward.id)
        if let expiresAt = coupon.expiresAt {
            await reminderScheduler.scheduleCouponReminder(couponId: coupon.id, title: reward.title, expiresAt: expiresAt)
        }
        return CouponItem(coupon: coupon, reward: reward)
    }
}
