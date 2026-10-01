import Observation

@Observable
final class CouponDetailViewModel {
    @ObservationIgnored private let observeCoupon: ObserveCouponUseCase
    @ObservationIgnored private let markCouponUsed: MarkCouponUsedUseCase

    private(set) var uiState: CouponDetailUiState

    init(
        item: CouponItem,
        observeCoupon: ObserveCouponUseCase,
        couponQrPayload: CouponQrPayloadUseCase,
        markCouponUsed: MarkCouponUsedUseCase
    ) {
        self.observeCoupon = observeCoupon
        self.markCouponUsed = markCouponUsed
        uiState = CouponDetailUiState(item: item, qrPayload: couponQrPayload.execute(coupon: item.coupon))
    }

    func observe() async {
        do {
            for try await coupon in observeCoupon.execute(couponId: uiState.item.id) {
                guard let coupon else {
                    continue
                }
                uiState.item = CouponItem(coupon: coupon, reward: uiState.item.reward)
            }
        } catch {
            return
        }
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
