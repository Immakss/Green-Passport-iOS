import Foundation
import Observation

@Observable
final class ShopViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchRewards: FetchRewardsUseCase
    @ObservationIgnored private let fetchCoupons: FetchCouponsUseCase
    @ObservationIgnored private let fetchPointsBalance: FetchPointsBalanceUseCase
    @ObservationIgnored private let purchaseReward: PurchaseRewardUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState = ShopUiState()
    private(set) var purchaseCount = 0
    var purchasedCoupon: CouponItem?

    init(
        observeSession: ObserveSessionUseCase,
        fetchRewards: FetchRewardsUseCase,
        fetchCoupons: FetchCouponsUseCase,
        fetchPointsBalance: FetchPointsBalanceUseCase,
        purchaseReward: PurchaseRewardUseCase
    ) {
        self.observeSession = observeSession
        self.fetchRewards = fetchRewards
        self.fetchCoupons = fetchCoupons
        self.fetchPointsBalance = fetchPointsBalance
        self.purchaseReward = purchaseReward
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await refresh()
        }
    }

    func refresh() async {
        uiState.hasError = false
        do {
            let rewards = try await fetchRewards.execute()
            var points = 0
            var activeCouponCount = 0
            if let userId {
                points = try await fetchPointsBalance.execute(userId: userId)
                let now = Date()
                activeCouponCount = try await fetchCoupons.execute(userId: userId)
                    .filter { return $0.coupon.status(at: now) == .active }
                    .count
            }
            uiState.rewards = rewards
            uiState.points = points
            uiState.activeCouponCount = activeCouponCount
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    func canAfford(_ reward: Reward) -> Bool {
        let canAfford = uiState.points >= reward.pointsCost
        uiState.hasInsufficientPoints = !canAfford
        return canAfford
    }

    func purchase(_ reward: Reward) {
        guard userId != nil, uiState.purchasingRewardId == nil, canAfford(reward) else {
            return
        }
        uiState.purchasingRewardId = reward.id
        Task {
            do {
                purchasedCoupon = try await purchaseReward.execute(reward: reward)
                purchaseCount += 1
                await refresh()
            } catch {
                uiState.hasInsufficientPoints = true
            }
            uiState.purchasingRewardId = nil
        }
    }
}
