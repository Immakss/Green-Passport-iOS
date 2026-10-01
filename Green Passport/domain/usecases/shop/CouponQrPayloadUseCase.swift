import Foundation

final class CouponQrPayloadUseCase {
    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(coupon: Coupon) -> String? {
        return shopRepository.scanUrl(for: coupon)?.absoluteString ?? coupon.code
    }
}
