import Foundation

protocol ShopRepository {
    func observeRewards() -> AsyncThrowingStream<[Reward], Error>
    func observePurchases(userId: String) -> AsyncThrowingStream<[Coupon], Error>
    func observePurchase(id: String) -> AsyncThrowingStream<Coupon?, Error>
    func scanUrl(for coupon: Coupon) -> URL?
}
