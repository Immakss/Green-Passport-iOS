import SwiftUI

struct MazeRoute: View {
    @State private var viewModel: MazeViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildMazeViewModel())
    }

    var body: some View {
        MazeScreen(uiState: viewModel.uiState, onMove: viewModel.move, onRestart: viewModel.restart)
    }
}
