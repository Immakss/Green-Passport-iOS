final class ObserveCouponUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(couponId: String) -> AsyncThrowingStream<Coupon?, Error> {
        return shopRepository.observePurchase(id: couponId)
    }
}
