import SwiftUI

struct ForumRoute: View {
    @State private var viewModel: ForumViewModel
    @State private var reloadId = 0

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildForumViewModel())
    }

    var body: some View {
        ForumScreen(
            uiState: viewModel.uiState,
            draft: Binding(get: { return viewModel.uiState.draft }, set: viewModel.updateDraft),
            onPost: viewModel.post,
            onReport: viewModel.report,
            onRetry: { reloadId += 1 }
        )
        .task(id: reloadId) {
            await viewModel.observe()
        }
        .sensoryFeedback(.success, trigger: viewModel.postedCount)
    }
}
