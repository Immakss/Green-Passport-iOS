import Observation

@Observable
final class CouponsViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeCoupons: ObserveCouponsUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var userId: String?

    var uiState = CouponsUiState()

    init(observeSession: ObserveSessionUseCase, observeCoupons: ObserveCouponsUseCase) {
        self.observeSession = observeSession
        self.observeCoupons = observeCoupons
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            guard let userId = session?.userId else {
                sessionTask.cancel()
                uiState.items = []
                uiState.isLoading = false
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
        sessionTask.run { [weak self] in
            await self?.observeItems(userId: userId)
        }
    }

    private func observeItems(userId: String) async {
        do {
            for try await items in observeCoupons.execute(userId: userId) {
                uiState.items = items
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState.isLoading = false
            uiState.hasError = uiState.items.isEmpty
        }
    }
}
