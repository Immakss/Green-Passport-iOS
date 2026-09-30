import Observation

@Observable
final class EcoTipDetailViewModel {
    @ObservationIgnored private let tipId: String
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchEcoTips: FetchEcoTipsUseCase
    @ObservationIgnored private let fetchReadTipIds: FetchReadTipIdsUseCase
    @ObservationIgnored private let markTipRead: MarkTipReadUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState = EcoTipDetailUiState()

    init(
        tipId: String,
        observeSession: ObserveSessionUseCase,
        fetchEcoTips: FetchEcoTipsUseCase,
        fetchReadTipIds: FetchReadTipIdsUseCase,
        markTipRead: MarkTipReadUseCase
    ) {
        self.tipId = tipId
        self.observeSession = observeSession
        self.fetchEcoTips = fetchEcoTips
        self.fetchReadTipIds = fetchReadTipIds
        self.markTipRead = markTipRead
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func load() async {
        uiState.hasError = false
        do {
            let tip = try await fetchEcoTips.execute().first { return $0.id == tipId }
            var readIds: Set<String> = []
            if let userId {
                readIds = try await fetchReadTipIds.execute(userId: userId)
            }
            uiState.tip = tip
            uiState.isRead = readIds.contains(tipId)
            uiState.hasError = tip == nil
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    func markRead() {
        guard userId != nil, !uiState.isRead, !uiState.isSubmitting else {
            return
        }
        uiState.isSubmitting = true
        Task {
            do {
                _ = try await markTipRead.execute(tipId: tipId)
                uiState.isRead = true
            } catch {
                uiState.isRead = false
            }
            uiState.isSubmitting = false
        }
    }
}
