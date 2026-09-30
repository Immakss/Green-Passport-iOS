struct ShopUiState {
    var points = 0
    var rewards: [Reward] = []
    var purchases: [Coupon] = []
    var purchasingRewardId: String?
    var hasInsufficientPoints = false
    var isLoading = true
    var hasError = false

    func rewardTitle(for coupon: Coupon) -> String {
        return rewards.first { return $0.id == coupon.rewardId }?.title ?? coupon.rewardId
    }
}
