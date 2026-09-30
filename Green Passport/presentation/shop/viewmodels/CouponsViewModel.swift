import Observation

@Observable
final class CouponsViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchCoupons: FetchCouponsUseCase
    @ObservationIgnored private var userId: String?

    var uiState = CouponsUiState()

    init(observeSession: ObserveSessionUseCase, fetchCoupons: FetchCouponsUseCase) {
        self.observeSession = observeSession
        self.fetchCoupons = fetchCoupons
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func load() async {
        guard let userId else {
            uiState.items = []
            uiState.isLoading = false
            return
        }
        uiState.hasError = false
        do {
            uiState.items = try await fetchCoupons.execute(userId: userId)
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }
}
