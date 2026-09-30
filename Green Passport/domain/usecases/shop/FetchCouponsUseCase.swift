final class FetchCouponsUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(userId: String) async throws -> [CouponItem] {
        async let rewards = shopRepository.fetchRewards()
        async let purchases = shopRepository.fetchPurchases(userId: userId)
        let rewardsById = Dictionary(try await rewards.map { return ($0.id, $0) }) { first, _ in
            return first
        }
        return try await purchases
            .sorted { return $0.redeemedAt > $1.redeemedAt }
            .map { return CouponItem(coupon: $0, reward: rewardsById[$0.rewardId]) }
    }
}
