import SwiftUI

struct TasksListRoute: View {
    let container: AppDIContainer

    @State private var viewModel: TasksListViewModel
    @State private var selectedTask: TaskSheetItem?

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildTasksListViewModel())
    }

    var body: some View {
        TasksListScreen(uiState: viewModel.uiState) { action in
            if case .taskSelected(let task) = action {
                selectedTask = TaskSheetItem(id: task.id)
            }
            viewModel.handle(action)
        }
        .task {
            await viewModel.observe()
        }
        .taskDetailSheet(item: $selectedTask, container: container)
    }
}
