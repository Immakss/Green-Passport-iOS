final class FetchRewardsUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute() async throws -> [Reward] {
        return try await shopRepository.fetchRewards()
    }
}
