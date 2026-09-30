import Foundation

struct CouponsUiState {
    var items: [CouponItem] = []
    var tab: CouponsTab = .active
    var isLoading = true
    var hasError = false

    func items(in tab: CouponsTab, at date: Date) -> [CouponItem] {
        return items.filter { return $0.coupon.status(at: date) == tab.status }
    }
}
