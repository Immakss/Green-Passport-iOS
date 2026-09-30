protocol ShopRepository {
    func fetchRewards() async throws -> [Reward]
    func fetchPurchases(userId: String) async throws -> [Coupon]
}
