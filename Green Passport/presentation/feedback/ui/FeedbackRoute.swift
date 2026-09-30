import SwiftUI

struct FeedbackRoute: View {
    @State private var viewModel: FeedbackViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildFeedbackViewModel())
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        FeedbackScreen(
            uiState: viewModel.uiState,
            rating: $viewModel.uiState.rating,
            reviewMessage: $viewModel.uiState.reviewMessage,
            suggestionMessage: $viewModel.uiState.suggestionMessage,
            onSubmitReview: viewModel.submitReview,
            onSubmitSuggestion: viewModel.submitSuggestion,
            onAnswerSurvey: viewModel.answerSurvey,
            onRetry: { Task { await viewModel.load() } }
        )
        .task {
            await viewModel.observe()
        }
    }
}
