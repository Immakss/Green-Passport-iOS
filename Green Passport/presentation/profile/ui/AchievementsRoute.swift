import SwiftUI

struct AchievementsRoute: View {
    @State private var viewModel: AchievementsViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildAchievementsViewModel())
    }

    var body: some View {
        AchievementsScreen(uiState: viewModel.uiState, onRetry: { Task { await viewModel.load() } })
            .task {
                await viewModel.observe()
            }
    }
}
