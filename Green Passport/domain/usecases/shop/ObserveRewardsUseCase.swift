final class ObserveRewardsUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute() -> AsyncThrowingStream<[Reward], Error> {
        return StreamCombiner.mapped(shopRepository.observeRewards()) { rewards in
            return rewards.filter { return $0.isActive }
        }
    }
}
