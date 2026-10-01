import Observation

@Observable
final class FavoritesViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeTasks: ObserveTasksUseCase
    @ObservationIgnored private let observeEcoTips: ObserveEcoTipsUseCase
    @ObservationIgnored private let observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase
    @ObservationIgnored private let observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var userId: String?
    @ObservationIgnored private var loadedSources: Set<FavoritesSource> = []

    private(set) var uiState = FavoritesUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeTasks: ObserveTasksUseCase,
        observeEcoTips: ObserveEcoTipsUseCase,
        observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase,
        observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase
    ) {
        self.observeSession = observeSession
        self.observeTasks = observeTasks
        self.observeEcoTips = observeEcoTips
        self.observeFavoriteTaskIds = observeFavoriteTaskIds
        self.observeBookmarkedTipIds = observeBookmarkedTipIds
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            guard let userId = session?.userId else {
                sessionTask.cancel()
                uiState = FavoritesUiState(isLoading: false)
                continue
            }
            start(userId: userId)
        }
        sessionTask.cancel()
    }

    func retry() {
        guard let userId else {
            return
        }
        uiState.isLoading = true
        uiState.hasError = false
        start(userId: userId)
    }

    private func start(userId: String) {
        loadedSources = []
        sessionTask.run { [weak self] in
            await self?.observeUserData(userId: userId)
        }
    }

    private func observeUserData(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeTaskList() }
            group.addTask { await self.observeTipList() }
            group.addTask { await self.observeFavorites(userId: userId) }
            group.addTask { await self.observeBookmarks(userId: userId) }
        }
    }

    private func observeTaskList() async {
        do {
            for try await tasks in observeTasks.execute() {
                uiState.tasks = tasks
                markLoaded(.tasks)
            }
        } catch {
            showError()
        }
    }

    private func observeTipList() async {
        do {
            for try await tips in observeEcoTips.execute() {
                uiState.tips = tips
                markLoaded(.tips)
            }
        } catch {
            showError()
        }
    }

    private func observeFavorites(userId: String) async {
        do {
            for try await ids in observeFavoriteTaskIds.execute(userId: userId) {
                uiState.favoriteTaskIds = ids
                markLoaded(.favoriteTaskIds)
            }
        } catch {
            showError()
        }
    }

    private func observeBookmarks(userId: String) async {
        do {
            for try await ids in observeBookmarkedTipIds.execute(userId: userId) {
                uiState.bookmarkedTipIds = ids
                markLoaded(.bookmarkedTipIds)
            }
        } catch {
            showError()
        }
    }

    private func markLoaded(_ source: FavoritesSource) {
        loadedSources.insert(source)
        guard loadedSources.count == FavoritesSource.allCases.count else {
            return
        }
        uiState.isLoading = false
        uiState.hasError = false
    }

    private func showError() {
        guard !Task.isCancelled else {
            return
        }
        uiState.isLoading = false
        uiState.hasError = true
    }
}
