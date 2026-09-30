import Observation

@Observable
final class HistoryViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchHistory: FetchHistoryUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState: ListUiState<HistoryEntry> = .loading

    init(observeSession: ObserveSessionUseCase, fetchHistory: FetchHistoryUseCase) {
        self.observeSession = observeSession
        self.fetchHistory = fetchHistory
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func load() async {
        guard let userId else {
            uiState = .success(data: [])
            return
        }
        do {
            uiState = .success(data: try await fetchHistory.execute(userId: userId))
        } catch {
            uiState = .error
        }
    }
}
