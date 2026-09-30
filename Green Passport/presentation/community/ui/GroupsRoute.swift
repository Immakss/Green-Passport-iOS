import SwiftUI

struct GroupsRoute: View {
    @State private var viewModel: GroupsViewModel
    @State private var reloadId = 0

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGroupsViewModel())
    }

    var body: some View {
        GroupsScreen(
            uiState: viewModel.uiState,
            draftName: Binding(get: { return viewModel.uiState.draftName }, set: viewModel.updateDraftName),
            onCreate: viewModel.create,
            onJoin: viewModel.join,
            onRetry: { reloadId += 1 }
        )
        .task(id: reloadId) {
            await viewModel.observe()
        }
    }
}
