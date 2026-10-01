final class ObserveRewardsUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute() -> AsyncThrowingStream<[Reward], Error> {
        return shopRepository.observeRewards()
    }
}
