import SwiftUI

struct EcoTipsListRoute: View {
    @Environment(TabRouter.self) private var router
    @State private var viewModel: EcoTipsListViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildEcoTipsListViewModel())
    }

    var body: some View {
        EcoTipsListScreen(
            uiState: viewModel.uiState,
            onFilter: viewModel.select,
            onTip: { router.push(.ecoTipDetail(tipId: $0.id)) },
            onToggleBookmark: viewModel.toggleBookmark,
            onRetry: viewModel.retry
        )
        .task {
            await viewModel.observe()
        }
    }
}
