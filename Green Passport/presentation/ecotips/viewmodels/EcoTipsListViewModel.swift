import Observation

@Observable
final class EcoTipsListViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchEcoTips: FetchEcoTipsUseCase
    @ObservationIgnored private let fetchReadTipIds: FetchReadTipIdsUseCase
    @ObservationIgnored private let observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase
    @ObservationIgnored private let toggleTipBookmark: ToggleTipBookmarkUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var userId: String?

    private(set) var uiState = EcoTipsListUiState()

    init(
        observeSession: ObserveSessionUseCase,
        fetchEcoTips: FetchEcoTipsUseCase,
        fetchReadTipIds: FetchReadTipIdsUseCase,
        observeBookmarkedTipIds: ObserveBookmarkedTipIdsUseCase,
        toggleTipBookmark: ToggleTipBookmarkUseCase
    ) {
        self.observeSession = observeSession
        self.fetchEcoTips = fetchEcoTips
        self.fetchReadTipIds = fetchReadTipIds
        self.observeBookmarkedTipIds = observeBookmarkedTipIds
        self.toggleTipBookmark = toggleTipBookmark
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            sessionTask.run { [weak self] in
                await self?.load()
                await self?.observeBookmarks()
            }
        }
        sessionTask.cancel()
    }

    func load() async {
        uiState.hasError = false
        do {
            uiState.tips = try await fetchEcoTips.execute()
            if let userId {
                uiState.readTipIds = try await fetchReadTipIds.execute(userId: userId)
            }
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    func reloadIfLoaded() async {
        guard !uiState.isLoading else {
            return
        }
        await load()
    }

    func select(_ filter: EcoTipFilter) {
        uiState.filter = filter
    }

    func toggleBookmark(_ tip: EcoTip) {
        guard let userId else {
            return
        }
        let isBookmarked = uiState.bookmarkedTipIds.contains(tip.id)
        Task {
            try? await toggleTipBookmark.execute(userId: userId, tipId: tip.id, isBookmarked: !isBookmarked)
        }
    }

    private func observeBookmarks() async {
        guard let userId else {
            return
        }
        do {
            for try await ids in observeBookmarkedTipIds.execute(userId: userId) {
                uiState.bookmarkedTipIds = ids
            }
        } catch {
            return
        }
    }
}
