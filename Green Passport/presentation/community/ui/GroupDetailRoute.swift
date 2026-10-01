import SwiftUI

struct GroupDetailRoute: View {
    @State private var viewModel: GroupDetailViewModel
    @State private var reloadId = 0

    init(groupId: String, container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGroupDetailViewModel(groupId: groupId))
    }

    var body: some View {
        GroupDetailScreen(
            uiState: viewModel.uiState,
            draft: Binding(get: { return viewModel.uiState.draft }, set: viewModel.updateDraft),
            onSend: viewModel.send,
            onJoin: viewModel.join,
            onLeave: viewModel.leave,
            onLoadMembers: viewModel.loadMembers,
            onRetryMessages: viewModel.retryMessages,
            onRetry: { reloadId += 1 }
        )
        .task(id: reloadId) {
            await viewModel.observe()
        }
    }
}
