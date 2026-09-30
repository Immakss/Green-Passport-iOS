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
        return Coupon(
            id: result[Self.resultCouponId] as? String ?? "",
            rewardId: rewardId,
            redeemedAt: EpochMillis.date(from: redeemedAt),
            expiresAt: nil
        )
    }

    private func callForReward(
        _ name: CloudFunctionName,
        data: [String: Any],
        reason: PointsEarnReason
    ) async throws -> RewardResult {
        let result = try await call(name, data: data)
        let reward = RewardResult(
            points: (result[Self.resultPoints] as? NSNumber)?.intValue ?? 0,
            xp: (result[Self.resultXp] as? NSNumber)?.intValue ?? 0
        )
        if reward.points > 0 || reward.xp > 0 {
            await rewardNotifier.notifyReward(reason: reason, points: reward.points, xp: reward.xp)
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
