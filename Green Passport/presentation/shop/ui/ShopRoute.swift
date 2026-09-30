import SwiftUI

struct ShopRoute: View {
    @State private var viewModel: ShopViewModel
    @State private var pendingReward: Reward?

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildShopViewModel())
    }

    var body: some View {
        ShopScreen(
            uiState: viewModel.uiState,
            onPurchase: { reward in
                if viewModel.canAfford(reward) {
                    pendingReward = reward
                }
            },
            onRefresh: viewModel.refresh
        )
        .task {
            await viewModel.observe()
        }
        .confirmationDialog(
            Text(.shopPurchaseButton),
            isPresented: Binding(get: { return pendingReward != nil }, set: { if !$0 { pendingReward = nil } }),
            titleVisibility: .visible,
            presenting: pendingReward
        ) { reward in
            Button {
                viewModel.purchase(reward)
            } label: {
                Text(.shopPurchaseButton)
            }
        } message: { reward in
            Text(.exchangePointsForRewardMsg(reward.pointsCost, reward.title))
        }
        .sensoryFeedback(.success, trigger: viewModel.purchaseCount)
    }
}
