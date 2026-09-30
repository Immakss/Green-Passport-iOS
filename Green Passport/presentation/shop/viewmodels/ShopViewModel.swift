import Observation

@Observable
final class ShopViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchRewards: FetchRewardsUseCase
    @ObservationIgnored private let fetchPurchases: FetchPurchasesUseCase
    @ObservationIgnored private let fetchPointsBalance: FetchPointsBalanceUseCase
    @ObservationIgnored private let purchaseReward: PurchaseRewardUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState = ShopUiState()
    private(set) var purchaseCount = 0

    init(
        observeSession: ObserveSessionUseCase,
        fetchRewards: FetchRewardsUseCase,
        fetchPurchases: FetchPurchasesUseCase,
        fetchPointsBalance: FetchPointsBalanceUseCase,
        purchaseReward: PurchaseRewardUseCase
    ) {
        self.observeSession = observeSession
        self.fetchRewards = fetchRewards
        self.fetchPurchases = fetchPurchases
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
            var purchases: [Coupon] = []
            if let userId {
                points = try await fetchPointsBalance.execute(userId: userId)
                purchases = try await fetchPurchases.execute(userId: userId)
            }
            uiState.rewards = rewards
            uiState.points = points
            uiState.purchases = purchases
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
                _ = try await purchaseReward.execute(reward: reward)
                purchaseCount += 1
                await refresh()
            } catch {
                uiState.hasInsufficientPoints = true
            }
            uiState.purchasingRewardId = nil
        }
    }
}
