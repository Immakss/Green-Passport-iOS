import Observation

@Observable
final class AchievementsViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchAchievements: FetchAchievementsUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState: ListUiState<Achievement> = .loading

    init(observeSession: ObserveSessionUseCase, fetchAchievements: FetchAchievementsUseCase) {
        self.observeSession = observeSession
        self.fetchAchievements = fetchAchievements
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func load() async {
        guard let userId else {
            return
        }
        do {
            uiState = .success(data: try await fetchAchievements.execute(userId: userId))
        } catch {
            uiState = .error
        }
    }
}
