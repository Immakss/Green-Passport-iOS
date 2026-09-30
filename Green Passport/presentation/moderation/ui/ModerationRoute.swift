import SwiftUI

struct ModerationRoute: View {
    @State private var viewModel: ModerationViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildModerationViewModel())
    }

    var body: some View {
        ModerationScreen(
            uiState: viewModel.uiState,
            onReview: viewModel.review,
            onModerate: viewModel.moderate
        )
        .task {
            await viewModel.observe()
        }
    }
}
