import Observation

@Observable
final class CouponDetailViewModel {
    @ObservationIgnored private let markCouponUsed: MarkCouponUsedUseCase

    private(set) var uiState: CouponDetailUiState

    init(item: CouponItem, markCouponUsed: MarkCouponUsedUseCase) {
        self.markCouponUsed = markCouponUsed
        uiState = CouponDetailUiState(item: item)
    }

    func markUsed() {
        guard !uiState.isMarking else {
            return
        }
        uiState.isMarking = true
        uiState.failure = nil
        Task {
            do {
                let usedAt = try await markCouponUsed.execute(couponId: uiState.item.id)
                let coupon = uiState.item.coupon
                uiState.item = CouponItem(
                    coupon: Coupon(
                        id: coupon.id,
                        rewardId: coupon.rewardId,
                        code: coupon.code,
                        redeemedAt: coupon.redeemedAt,
                        expiresAt: coupon.expiresAt,
                        usedAt: usedAt
                    ),
                    reward: uiState.item.reward
                )
            } catch {
                uiState.failure = (error as? RewardFailureError)?.failure ?? .unknown
            }
            uiState.isMarking = false
        }
    }
}
