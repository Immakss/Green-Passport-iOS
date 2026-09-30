import SwiftUI

struct WasteSortingRoute: View {
    @State private var viewModel: WasteSortingViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildWasteSortingViewModel())
    }

    var body: some View {
        WasteSortingScreen(uiState: viewModel.uiState, onSelect: viewModel.select, onRestart: viewModel.restart)
            .onAppear(perform: viewModel.start)
            .onDisappear(perform: viewModel.stop)
    }
}
