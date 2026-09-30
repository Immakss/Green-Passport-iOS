import Foundation

protocol RewardsRepository {
    func completeSelfTask(taskId: String) async throws -> RewardResult
    func redeemTaskCode(_ code: String) async throws -> RewardResult
    func checkInEvent(code: String) async throws -> RewardResult
    func submitFeedback(type: FeedbackType, message: String, rating: Int?) async throws -> RewardResult
    func submitSurveyAnswer(surveyId: String, optionIndex: Int) async throws -> RewardResult
    func recordTipRead(tipId: String) async throws -> RewardResult
    func recordGameResult(gameId: String, score: Int) async throws -> RewardResult
    func redeemReward(rewardId: String) async throws -> Coupon
    func markCouponUsed(couponId: String) async throws -> Date
}
