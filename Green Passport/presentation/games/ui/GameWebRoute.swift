import SwiftUI

struct GameWebRoute: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: GameWebViewModel
    @State private var reloadId = 0

    init(game: Game, container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGameWebViewModel(game: game))
    }

    var body: some View {
        GameWebScreen(
            title: viewModel.game.title,
            url: viewModel.url(isDark: colorScheme == .dark),
            uiState: viewModel.uiState,
            reloadId: reloadId,
            onMessage: handle,
            onLoadingChange: { viewModel.uiState.isLoading = $0 },
            onFailure: {
                viewModel.uiState.isLoading = false
                viewModel.uiState.hasError = true
            },
            onRetry: {
                viewModel.uiState.hasError = false
                viewModel.uiState.isLoading = true
                reloadId += 1
            },
            onClose: { dismiss() }
        )
    }

    private func handle(_ message: GameBridgeMessage) {
        switch message {
        case .finish(let score):
            viewModel.finish(score: score)
        case .close:
            dismiss()
        }
    }
}
