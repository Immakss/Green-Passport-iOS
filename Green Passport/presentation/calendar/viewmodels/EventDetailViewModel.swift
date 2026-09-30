import Observation

@Observable
final class EventDetailViewModel {
    @ObservationIgnored private let eventId: String
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchEvents: FetchEventsUseCase
    @ObservationIgnored private let fetchRegisteredEventIds: FetchRegisteredEventIdsUseCase
    @ObservationIgnored private let registerForEvent: RegisterForEventUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState = EventDetailUiState()

    init(
        eventId: String,
        observeSession: ObserveSessionUseCase,
        fetchEvents: FetchEventsUseCase,
        fetchRegisteredEventIds: FetchRegisteredEventIdsUseCase,
        registerForEvent: RegisterForEventUseCase
    ) {
        self.eventId = eventId
        self.observeSession = observeSession
        self.fetchEvents = fetchEvents
        self.fetchRegisteredEventIds = fetchRegisteredEventIds
        self.registerForEvent = registerForEvent
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func retry() {
        Task { await load() }
    }

    func signUp() {
        guard let userId, let event = uiState.event, !uiState.isRegistered, !uiState.isRegistering else {
            return
        }
        uiState.isRegistering = true
        Task {
            do {
                try await registerForEvent.execute(userId: userId, event: event)
                uiState.isRegistered = true
            } catch {
                uiState.isRegistered = false
            }
            uiState.isRegistering = false
        }
    }

    private func load() async {
        uiState.isLoading = true
        uiState.hasError = false
        do {
            let event = try await fetchEvents.execute().first { $0.id == eventId }
            var registeredIds: Set<String> = []
            if let userId {
                registeredIds = try await fetchRegisteredEventIds.execute(userId: userId)
            }
            uiState.event = event
            uiState.isRegistered = registeredIds.contains(eventId)
            uiState.isLoading = false
            uiState.hasError = event == nil
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }
}
