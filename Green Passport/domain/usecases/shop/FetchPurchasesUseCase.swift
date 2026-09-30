final class FetchPurchasesUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(userId: String) async throws -> [Coupon] {
        return try await shopRepository.fetchPurchases(userId: userId).sorted { $0.redeemedAt > $1.redeemedAt }
    }
}
