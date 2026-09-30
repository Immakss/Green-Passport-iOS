import SwiftUI

struct GamesHubRoute: View {
    @Environment(TabRouter.self) private var router
    @State private var viewModel: GamesHubViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGamesHubViewModel())
    }

    var body: some View {
        GamesHubScreen(
            uiState: viewModel.uiState,
            bestScores: viewModel.bestScores,
            onGame: { router.push(.game($0)) },
            onRetry: { Task { await viewModel.load() } }
        )
        .task {
            await viewModel.load()
        }
        .onAppear(perform: viewModel.refreshScores)
    }
}
