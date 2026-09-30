import FirebaseFunctions
import Foundation

final class FirebaseRewardsRepository: RewardsRepository {
    private static let paramTaskId = "taskId"
    private static let paramCode = "code"
    private static let paramTipId = "tipId"
    private static let paramGameId = "gameId"
    private static let paramScore = "score"
    private static let paramRewardId = "rewardId"
    private static let resultPoints = "points"
    private static let resultXp = "xp"
    private static let resultCouponId = "couponId"
    private static let resultRedeemedAt = "redeemedAtEpochMillis"
    private static let resultCode = "code"
    private static let resultExpiresAt = "expiresAtEpochMillis"
    private static let resultUsedAt = "usedAtEpochMillis"
    private static let paramCouponId = "couponId"
    private static let paramType = "type"
    private static let paramMessage = "message"
    private static let paramRating = "rating"
    private static let paramSurveyId = "surveyId"
    private static let paramOptionIndex = "optionIndex"
    private static let resultStreakBonus = "streakBonus"

    private let functions: Functions
    private let rewardNotifier: RewardNotifier

    init(functions: Functions, rewardNotifier: RewardNotifier) {
        self.functions = functions
        self.rewardNotifier = rewardNotifier
    }

    func completeSelfTask(taskId: String) async throws -> RewardResult {
        return try await callForReward(.completeSelfTask, data: [Self.paramTaskId: taskId], reason: .taskCompleted)
    }

    func redeemTaskCode(_ code: String) async throws -> RewardResult {
        return try await callForReward(.redeemTaskCode, data: [Self.paramCode: code], reason: .taskCompleted)
    }

    func checkInEvent(code: String) async throws -> RewardResult {
        return try await callForReward(.checkInEvent, data: [Self.paramCode: code], reason: .eventAttended)
    }

    func submitFeedback(type: FeedbackType, message: String, rating: Int?) async throws -> RewardResult {
        var data: [String: Any] = [Self.paramType: type.rawValue, Self.paramMessage: message]
        if let rating {
            data[Self.paramRating] = rating
        }
        return try await callForReward(.submitFeedback, data: data, reason: .feedbackSubmitted)
    }

    func submitSurveyAnswer(surveyId: String, optionIndex: Int) async throws -> RewardResult {
        return try await callForReward(
            .submitSurveyAnswer,
            data: [Self.paramSurveyId: surveyId, Self.paramOptionIndex: optionIndex],
            reason: .surveyAnswered
        )
    }

    func recordTipRead(tipId: String) async throws -> RewardResult {
        return try await callForReward(.recordTipRead, data: [Self.paramTipId: tipId], reason: .articleRead)
    }

    func recordGameResult(gameId: String, score: Int) async throws -> RewardResult {
        return try await callForReward(
            .recordGameResult,
            data: [Self.paramGameId: gameId, Self.paramScore: score],
            reason: .gamePlayed
        )
    }

    func redeemReward(rewardId: String) async throws -> Coupon {
        let result = try await call(.redeemReward, data: [Self.paramRewardId: rewardId])
        let redeemedAt = (result[Self.resultRedeemedAt] as? NSNumber)?.int64Value ?? EpochMillis.now
        let expiresAt = (result[Self.resultExpiresAt] as? NSNumber)?.int64Value
        return Coupon(
            id: result[Self.resultCouponId] as? String ?? "",
            rewardId: rewardId,
            code: result[Self.resultCode] as? String,
            redeemedAt: EpochMillis.date(from: redeemedAt),
            expiresAt: expiresAt.map(EpochMillis.date(from:)),
            usedAt: nil
        )
    }

    func markCouponUsed(couponId: String) async throws -> Date {
        let result = try await call(.markCouponUsed, data: [Self.paramCouponId: couponId])
        let usedAt = (result[Self.resultUsedAt] as? NSNumber)?.int64Value ?? EpochMillis.now
        return EpochMillis.date(from: usedAt)
    }

    private func callForReward(
        _ name: CloudFunctionName,
        data: [String: Any],
        reason: PointsEarnReason
    ) async throws -> RewardResult {
        let result = try await call(name, data: data)
        let reward = RewardResult(
            points: (result[Self.resultPoints] as? NSNumber)?.intValue ?? 0,
            xp: (result[Self.resultXp] as? NSNumber)?.intValue ?? 0,
            streakBonus: (result[Self.resultStreakBonus] as? NSNumber)?.intValue ?? 0
        )
        if reward.points > 0 || reward.xp > 0 {
            await rewardNotifier.notifyReward(reason: reason, points: reward.points, xp: reward.xp)
        }
        if reward.streakBonus > 0 {
            await rewardNotifier.notifyReward(reason: .streakBonus, points: reward.streakBonus, xp: reward.streakBonus)
        }
        return reward
    }

    private func call(_ name: CloudFunctionName, data: [String: Any]) async throws -> [String: Any] {
        do {
            let result = try await functions.httpsCallable(name.rawValue).call(data)
            return result.data as? [String: Any] ?? [:]
        } catch {
            throw RewardFailureError(failure: FunctionsErrorMapper.failure(from: error))
        }
    }
}
