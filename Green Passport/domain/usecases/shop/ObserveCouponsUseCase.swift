final class ObserveCouponsUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<[CouponItem], Error> {
        return StreamCombiner.latest(shopRepository.observeRewards(), shopRepository.observePurchases(userId: userId)) { rewards, purchases in
            let rewardsById = Dictionary(rewards.map { return ($0.id, $0) }) { first, _ in
                return first
            }
            return purchases
                .sorted { return $0.redeemedAt > $1.redeemedAt }
                .map { return CouponItem(coupon: $0, reward: rewardsById[$0.rewardId]) }
        }
    }
}
