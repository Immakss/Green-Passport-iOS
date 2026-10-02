import Foundation
import Observation

@Observable
final class ShopViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeRewards: ObserveRewardsUseCase
    @ObservationIgnored private let observeCoupons: ObserveCouponsUseCase
    @ObservationIgnored private let observeWallet: ObserveWalletUseCase
    @ObservationIgnored private let purchaseReward: PurchaseRewardUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var userId: String?

    private(set) var uiState = ShopUiState()
    private(set) var purchaseCount = 0
    var purchasedCoupon: CouponItem?

    init(
        observeSession: ObserveSessionUseCase,
        observeRewards: ObserveRewardsUseCase,
        observeCoupons: ObserveCouponsUseCase,
        observeWallet: ObserveWalletUseCase,
        purchaseReward: PurchaseRewardUseCase
    ) {
        self.observeSession = observeSession
        self.observeRewards = observeRewards
        self.observeCoupons = observeCoupons
        self.observeWallet = observeWallet
        self.purchaseReward = purchaseReward
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            start(userId: session?.userId)
        }
        sessionTask.cancel()
    }

    func retry() {
        uiState.isLoading = true
        uiState.hasError = false
        start(userId: userId)
    }

    func canAfford(_ reward: Reward) -> Bool {
        let canAfford = uiState.points >= reward.pointsCost
        uiState.purchaseFailure = canAfford ? nil : .notEnoughPoints
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
            } catch {
                uiState.purchaseFailure = (error as? RewardFailureError)?.failure ?? .unknown
            }
            uiState.purchasingRewardId = nil
        }
    }

    private func start(userId: String?) {
        sessionTask.run { [weak self] in
            await self?.observeData(userId: userId)
        }
    }

    private func observeData(userId: String?) async {
        guard let userId else {
            uiState.points = 0
            uiState.activeCouponCount = 0
            await observeRewardList()
            return
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeRewardList() }
            group.addTask { await self.observeBalance(userId: userId) }
            group.addTask { await self.observeActiveCoupons(userId: userId) }
        }
    }

    private func observeRewardList() async {
        do {
            for try await rewards in observeRewards.execute() {
                uiState.rewards = rewards
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState.isLoading = false
            uiState.hasError = uiState.rewards.isEmpty
        }
    }

    private func observeBalance(userId: String) async {
        do {
            for try await wallet in observeWallet.execute(userId: userId) {
                uiState.points = wallet.availablePoints
            }
        } catch {
            return
        }
    }

    private func observeActiveCoupons(userId: String) async {
        do {
            for try await coupons in observeCoupons.execute(userId: userId) {
                let now = Date()
                uiState.activeCouponCount = coupons.filter { return $0.coupon.status(at: now) == .active }.count
            }
        } catch {
            return
        }
    }
}
