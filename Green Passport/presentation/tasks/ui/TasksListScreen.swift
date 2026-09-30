import SwiftUI

struct TasksListScreen: View {
    private static let mascotSize: CGFloat = 34

    let uiState: TasksListUiState
    let onRefresh: () async -> Void
    let onAction: (TasksListUserAction) -> Void

    var body: some View {
        List {
            Section {
                FilterBar(
                    options: uiState.availableFilters,
                    selected: uiState.effectiveFilter,
                    title: { return $0.title },
                    onSelect: { onAction(.filterSelected($0)) }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .listSectionMargins(.horizontal, 0)
            content
        }
        .listStyle(.insetGrouped)
        .overlay {
            overlayState
        }
        .navigationTitle(Text(.homeTileTasks))
        .refreshable {
            await onRefresh()
        }
        .animation(.snappy, value: uiState.effectiveFilter)
    }

    @ViewBuilder
    private var content: some View {
        if !uiState.isLoading && !uiState.hasError && !uiState.visibleTasks.isEmpty {
            Section {
                ForEach(uiState.visibleTasks) { task in
                    row(for: task)
                }
            }
        }
    }

    @ViewBuilder
    private var overlayState: some View {
        if uiState.isLoading {
            StateView(kind: .loading)
        } else if uiState.hasError {
            StateView(kind: .error(retry: { onAction(.retry) }))
        } else if uiState.visibleTasks.isEmpty {
            StateView(kind: .empty(message: .tasksEmpty))
        }
    }

    private func row(for task: EcoTask) -> some View {
        let isCompleted = uiState.completedTaskIds.contains(task.id)
        let isFavorite = uiState.favoriteTaskIds.contains(task.id)
        return Button {
            onAction(.taskSelected(task))
        } label: {
            ListRow(title: task.title, subtitle: subtitle(for: task, isCompleted: isCompleted)) {
                MascotImage(size: Self.mascotSize)
            } trailing: {
                if !isCompleted {
                    PointsBadge(points: task.rewardPoints)
                }
                Button {
                    onAction(.favoriteToggled(task))
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? SectionColor.feedback : Palette.secondaryText)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Text(.profileFavorites))
                .sensoryFeedback(.impact, trigger: isFavorite)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button {
                onAction(.favoriteToggled(task))
            } label: {
                Image(systemName: isFavorite ? "heart.slash.fill" : "heart.fill")
            }
            .tint(SectionColor.feedback)
        }
    }

    private func subtitle(for task: EcoTask, isCompleted: Bool) -> String? {
        if isCompleted {
            return String(localized: .taskDetailCompletedLabel)
        }
        if uiState.pendingTaskIds.contains(task.id) {
            return String(localized: .underReview)
        }
        return String(localized: task.category.title)
    }
}

#Preview {
    NavigationStack {
        TasksListScreen(
            uiState: TasksListUiState(tasks: EcoTask.placeholders(count: 4), isLoading: false),
            onRefresh: {},
            onAction: { _ in }
        )
    }
}
