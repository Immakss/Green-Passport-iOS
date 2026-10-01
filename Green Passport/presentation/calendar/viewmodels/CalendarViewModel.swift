import Observation

@Observable
final class CalendarViewModel {
    @ObservationIgnored private let observeEvents: ObserveEventsUseCase

    private(set) var uiState: ListUiState<EcoEvent> = .loading
    private(set) var observationId = 0

    init(observeEvents: ObserveEventsUseCase) {
        self.observeEvents = observeEvents
    }

    func observe() async {
        do {
            for try await events in observeEvents.execute() {
                uiState = .success(data: events)
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState = .error
        }
    }

    func retry() {
        uiState = .loading
        observationId += 1
    }
}
