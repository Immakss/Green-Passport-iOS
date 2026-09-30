import Foundation

final class MarkCouponUsedUseCase {
    private let rewardsRepository: RewardsRepository
    private let reminderScheduler: ReminderScheduler

    init(rewardsRepository: RewardsRepository, reminderScheduler: ReminderScheduler) {
        self.rewardsRepository = rewardsRepository
        self.reminderScheduler = reminderScheduler
    }

    func execute(couponId: String) async throws -> Date {
        let usedAt = try await rewardsRepository.markCouponUsed(couponId: couponId)
        reminderScheduler.cancelCouponReminder(couponId: couponId)
        return usedAt
    }
}
