import SwiftUI

struct HomeRoute: View {
    let container: AppDIContainer

    @Environment(TabRouter.self) private var router
    @State private var viewModel: HomeViewModel
    @State private var selectedTask: TaskSheetItem?
    @State private var selectedEvent: EventSheetItem?

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildHomeViewModel())
    }

    var body: some View {
        HomeScreen(
            uiState: viewModel.uiState,
            onProfile: { router.push(.profile) },
            onQuickAction: { router.push($0.destination) },
            onEvent: { selectedEvent = EventSheetItem(id: $0.id) },
            onTask: { selectedTask = TaskSheetItem(id: $0.id) },
            onAllTasks: { router.push(.tasks) },
            onRetry: viewModel.retry
        )
        .task {
            await viewModel.observe()
        }
        .taskDetailSheet(item: $selectedTask, container: container)
        .eventDetailSheet(item: $selectedEvent, container: container)
    }
}
