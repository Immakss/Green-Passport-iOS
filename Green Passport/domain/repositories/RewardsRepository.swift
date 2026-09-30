import Foundation

protocol RewardsRepository {
    func completeSelfTask(taskId: String) async throws -> RewardResult
    func redeemTaskCode(_ code: String) async throws -> RewardResult
    func recordTipRead(tipId: String) async throws -> RewardResult
    func recordGameResult(gameId: String, score: Int) async throws -> RewardResult
    func redeemReward(rewardId: String) async throws -> Coupon
    func markCouponUsed(couponId: String) async throws -> Date
}
