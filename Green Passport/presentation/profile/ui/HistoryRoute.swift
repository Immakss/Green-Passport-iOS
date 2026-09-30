import SwiftUI

struct HistoryRoute: View {
    @State private var viewModel: HistoryViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildHistoryViewModel())
    }

    var body: some View {
        HistoryScreen(uiState: viewModel.uiState, onRetry: { Task { await viewModel.load() } })
            .task {
                await viewModel.observe()
            }
            .refreshable {
                await viewModel.load()
            }
    }
}
