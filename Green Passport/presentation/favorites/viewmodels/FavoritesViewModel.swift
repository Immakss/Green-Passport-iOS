import Observation

@Observable
final class FavoritesViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchTasks: FetchTasksUseCase
    @ObservationIgnored private let fetchEcoTips: FetchEcoTipsUseCase
    @ObservationIgnored private let observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase
    @ObservationIgnored private let observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase
    @ObservationIgnored private let sessionTask = LatestTask()

    private(set) var uiState = FavoritesUiState()

    init(
        observeSession: ObserveSessionUseCase,
        fetchTasks: FetchTasksUseCase,
        fetchEcoTips: FetchEcoTipsUseCase,
        observeFavoriteTaskIds: ObserveFavoriteTaskIdsUseCase,
        observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase
    ) {
        self.observeSession = observeSession
        self.fetchTasks = fetchTasks
        self.fetchEcoTips = fetchEcoTips
        self.observeFavoriteTaskIds = observeFavoriteTaskIds
        self.observeBookmarkedTipIds = observeBookmarkedTipIds
    }

    func observe() async {
        for await session in observeSession.execute() {
            guard let userId = session?.userId else {
                sessionTask.cancel()
                uiState = FavoritesUiState(isLoading: false)
                continue
            }
            sessionTask.run { [weak self] in
                await self?.observeUserData(userId: userId)
            }
        }
        sessionTask.cancel()
    }

    func load() async {
        uiState.hasError = false
        do {
            async let tasks = fetchTasks.execute()
            async let tips = fetchEcoTips.execute()
            uiState.tasks = try await tasks
            uiState.tips = try await tips
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    private func observeUserData(userId: String) async {
        await load()
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeFavorites(userId: userId) }
            group.addTask { await self.observeBookmarks(userId: userId) }
        }
    }

    private func observeFavorites(userId: String) async {
        do {
            for try await ids in observeFavoriteTaskIds.execute(userId: userId) {
                uiState.favoriteTaskIds = ids
            }
        } catch {
            return
        }
    }

    private func observeBookmarks(userId: String) async {
        do {
            for try await ids in observeBookmarkedTipIds.execute(userId: userId) {
                uiState.bookmarkedTipIds = ids
            }
        } catch {
            return
        }
    }
}
