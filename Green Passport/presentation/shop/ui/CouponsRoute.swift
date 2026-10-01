import SwiftUI

struct CouponsRoute: View {
    let container: AppDIContainer

    @State private var viewModel: CouponsViewModel
    @State private var selectedCoupon: CouponItem?

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildCouponsViewModel())
    }

    var body: some View {
        CouponsScreen(
            uiState: viewModel.uiState,
            tab: $viewModel.uiState.tab,
            onCoupon: { selectedCoupon = $0 },
            onRetry: viewModel.retry
        )
        .task {
            await viewModel.observe()
        }
        .couponDetailSheet(item: $selectedCoupon, container: container)
    }
}
