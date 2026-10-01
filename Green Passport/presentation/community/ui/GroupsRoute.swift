import SwiftUI

struct GroupsRoute: View {
    @Environment(TabRouter.self) private var router
    @State private var viewModel: GroupsViewModel
    @State private var reloadId = 0

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGroupsViewModel())
    }

    var body: some View {
        GroupsScreen(
            uiState: viewModel.uiState,
            draftName: Binding(get: { return viewModel.uiState.draftName }, set: viewModel.updateDraftName),
            inviteCode: Binding(get: { return viewModel.uiState.inviteCodeDraft }, set: viewModel.updateInviteCodeDraft),
            onCreate: viewModel.create,
            onJoin: viewModel.join,
            onOpen: { group in router.push(.group(id: group.id)) },
            onJoinByCode: joinByCode,
            onDismissNotFound: viewModel.dismissInviteCodeNotFound,
            onRetry: { reloadId += 1 }
        )
        .task(id: reloadId) {
            await viewModel.observe()
        }
    }

    private func joinByCode() {
        Task {
            if let groupId = await viewModel.joinByCode() {
                router.push(.group(id: groupId))
            }
        }
    }
}
