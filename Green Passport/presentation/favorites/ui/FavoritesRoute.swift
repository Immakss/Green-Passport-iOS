import SwiftUI

struct FavoritesRoute: View {
    let container: AppDIContainer

    @Environment(TabRouter.self) private var router
    @State private var viewModel: FavoritesViewModel
    @State private var segment = FavoritesSegment.tasks
    @State private var selectedTask: TaskSheetItem?

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildFavoritesViewModel())
    }

    var body: some View {
        FavoritesScreen(
            uiState: viewModel.uiState,
            segment: $segment,
            onTask: { selectedTask = TaskSheetItem(id: $0.id) },
            onTip: { router.push(.ecoTipDetail(tipId: $0.id)) },
            onRetry: viewModel.retry
        )
        .task {
            await viewModel.observe()
        }
        .taskDetailSheet(item: $selectedTask, container: container)
    }
}
