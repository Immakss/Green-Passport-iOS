import SwiftUI

struct PuzzleRoute: View {
    @State private var viewModel: PuzzleViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildPuzzleViewModel())
    }

    var body: some View {
        PuzzleScreen(uiState: viewModel.uiState, onFlip: viewModel.flip, onRestart: viewModel.restart)
    }
}
