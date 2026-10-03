import Foundation
import Observation

@Observable
final class CalendarViewModel {
    @ObservationIgnored private let observeEvents: ObserveEventsUseCase
    @ObservationIgnored private var hasChosenInitialDay = false

    private(set) var uiState: ListUiState<EcoEvent> = .loading
    private(set) var selectedDay = DateComponents.day(containing: .now)
    private(set) var observationId = 0

    init(observeEvents: ObserveEventsUseCase) {
        self.observeEvents = observeEvents
    }

    func observe() async {
        do {
            for try await events in observeEvents.execute() {
                chooseInitialDay(from: events)
                uiState = .success(data: events)
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState = .error
        }
    }

    func selectDay(_ day: DateComponents) {
        selectedDay = day
    }

    func retry() {
        uiState = .loading
        observationId += 1
    }

    private func chooseInitialDay(from events: [EcoEvent]) {
        guard !hasChosenInitialDay else {
            return
        }
        hasChosenInitialDay = true
        let startOfToday = Calendar.current.startOfDay(for: .now)
        if let nextEvent = events.first(where: { return $0.startAt >= startOfToday }) {
            selectedDay = nextEvent.day
        }
    }
}
