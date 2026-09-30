nonisolated struct CouponItem: Identifiable, Hashable, Sendable {
    let coupon: Coupon
    let reward: Reward?

    var id: String {
        return coupon.id
    }

    var title: String {
        return reward?.title ?? coupon.rewardId
    }
}
