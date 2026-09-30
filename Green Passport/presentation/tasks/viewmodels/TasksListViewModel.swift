import Observation

@Observable
final class TasksListViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let fetchTasks: FetchTasksUseCase
    @ObservationIgnored private let fetchCompletedTaskIds: FetchCompletedTaskIdsUseCase
    @ObservationIgnored private let observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase
    @ObservationIgnored private let toggleTaskFavorite: ToggleTaskFavoriteUseCase
    @ObservationIgnored private let observeTaskSubmissions: ObserveTaskSubmissionsUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var userId: String?

    private(set) var uiState = TasksListUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        fetchTasks: FetchTasksUseCase,
        fetchCompletedTaskIds: FetchCompletedTaskIdsUseCase,
        observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase,
        toggleTaskFavorite: ToggleTaskFavoriteUseCase,
        observeTaskSubmissions: ObserveTaskSubmissionsUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.fetchTasks = fetchTasks
        self.fetchCompletedTaskIds = fetchCompletedTaskIds
        self.observeFavoriteTaskIds = observeFavoriteTaskIds
        self.toggleTaskFavorite = toggleTaskFavorite
        self.observeTaskSubmissions = observeTaskSubmissions
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            sessionTask.run { [weak self] in
                await self?.observeUserData(userId: session?.userId)
            }
        }
        sessionTask.cancel()
    }

    func refresh() async {
        uiState.hasError = false
        do {
            let tasks = try await fetchTasks.execute()
            var completedIds: Set<String> = []
            if let userId {
                completedIds = try await fetchCompletedTaskIds.execute(userId: userId)
            }
            uiState.tasks = tasks
            uiState.completedTaskIds = completedIds
            uiState.isLoading = false
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }

    func handle(_ action: TasksListUserAction) {
        switch action {
        case .filterSelected(let filter):
            uiState.filter = filter
        case .favoriteToggled(let task):
            toggleFavorite(task)
        case .taskSelected:
            break
        case .retry:
            uiState.isLoading = true
            Task { await refresh() }
        }
    }

    private func observeUserData(userId: String?) async {
        await refresh()
        guard let userId else {
            return
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeSubmissions(userId: userId) }
            group.addTask { await self.observeProfile(userId: userId) }
            group.addTask { await self.observeFavorites(userId: userId) }
        }
    }

    private func observeSubmissions(userId: String) async {
        do {
            for try await submissions in observeTaskSubmissions.execute(userId: userId) {
                uiState.pendingTaskIds = Set(submissions.filter { $0.status == .pending }.map(\.taskId))
            }
        } catch {
            uiState.pendingTaskIds = []
        }
    }

    private func observeProfile(userId: String) async {
        do {
            for try await profile in observeUserProfile.execute(userId: userId) {
                uiState.profile = profile
            }
        } catch {
            uiState.profile = nil
        }
    }

    private func observeFavorites(userId: String) async {
        do {
            for try await favoriteIds in observeFavoriteTaskIds.execute(userId: userId) {
                uiState.favoriteTaskIds = favoriteIds
            }
        } catch {
            return
        }
    }

    private func toggleFavorite(_ task: EcoTask) {
        guard let userId else {
            return
        }
        let isFavorite = uiState.favoriteTaskIds.contains(task.id)
        Task {
            try? await toggleTaskFavorite.execute(userId: userId, taskId: task.id, isFavorite: !isFavorite)
        }
    }
}
