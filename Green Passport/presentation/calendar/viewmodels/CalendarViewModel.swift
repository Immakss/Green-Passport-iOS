import Observation

@Observable
final class CalendarViewModel {
    @ObservationIgnored private let fetchEvents: FetchEventsUseCase

    private(set) var uiState: ListUiState<EcoEvent> = .loading

    init(fetchEvents: FetchEventsUseCase) {
        self.fetchEvents = fetchEvents
    }

    func load() async {
        do {
            uiState = .success(data: try await fetchEvents.execute())
        } catch {
            uiState = .error
        }
    }
}
