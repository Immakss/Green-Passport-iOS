struct ShopUiState {
    var points = 0
    var rewards: [Reward] = []
    var activeCouponCount = 0
    var purchasingRewardId: String?
    var purchaseFailure: RewardFailure?
    var isLoading = true
    var hasError = false
}
