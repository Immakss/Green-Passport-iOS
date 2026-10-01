import Observation

@Observable
final class EventDetailViewModel {
    @ObservationIgnored private let eventId: String
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeEvents: ObserveEventsUseCase
    @ObservationIgnored private let observeRegisteredEventIds: ObserveRegisteredEventIdsUseCase
    @ObservationIgnored private let registerForEvent: RegisterForEventUseCase
    @ObservationIgnored private let observeAttendedEventIds: ObserveAttendedEventIdsUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private let checkInEvent: CheckInEventUseCase
    @ObservationIgnored private var userId: String?

    private(set) var uiState = EventDetailUiState()

    init(
        eventId: String,
        observeSession: ObserveSessionUseCase,
        observeEvents: ObserveEventsUseCase,
        observeRegisteredEventIds: ObserveRegisteredEventIdsUseCase,
        registerForEvent: RegisterForEventUseCase,
        observeAttendedEventIds: ObserveAttendedEventIdsUseCase,
        checkInEvent: CheckInEventUseCase
    ) {
        self.eventId = eventId
        self.observeSession = observeSession
        self.observeEvents = observeEvents
        self.observeRegisteredEventIds = observeRegisteredEventIds
        self.registerForEvent = registerForEvent
        self.observeAttendedEventIds = observeAttendedEventIds
        self.checkInEvent = checkInEvent
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            start(userId: session?.userId)
        }
        sessionTask.cancel()
    }

    func retry() {
        uiState.isLoading = true
        uiState.hasError = false
        start(userId: userId)
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

    func checkIn(code: String) {
        guard userId != nil, !uiState.isCheckedIn, !uiState.isCheckingIn else {
            return
        }
        uiState.isCheckingIn = true
        uiState.checkInFailure = nil
        Task {
            do {
                let reward = try await checkInEvent.execute(code: code)
                uiState.isCheckedIn = true
                uiState.isRegistered = true
                uiState.checkInPoints = reward.points
                uiState.streakBonus = reward.streakBonus
            } catch {
                let failure = (error as? RewardFailureError)?.failure ?? .unknown
                uiState.checkInFailure = failure
                uiState.isCheckedIn = failure == .alreadyCompleted
            }
            uiState.isCheckingIn = false
        }
    }

    private func start(userId: String?) {
        sessionTask.run { [weak self] in
            await self?.observeData(userId: userId)
        }
    }

    private func observeData(userId: String?) async {
        guard let userId else {
            await observeEvent()
            return
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeEvent() }
            group.addTask { await self.observeRegistration(userId: userId) }
            group.addTask { await self.observeAttendance(userId: userId) }
        }
    }

    private func observeEvent() async {
        do {
            for try await events in observeEvents.execute() {
                let event = events.first { return $0.id == eventId }
                uiState.event = event
                uiState.isLoading = false
                uiState.hasError = event == nil
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState.isLoading = false
            uiState.hasError = uiState.event == nil
        }
    }

    private func observeRegistration(userId: String) async {
        do {
            for try await registeredIds in observeRegisteredEventIds.execute(userId: userId) {
                uiState.isRegistered = uiState.isRegistered || registeredIds.contains(eventId)
            }
        } catch {
            return
        }
    }

    private func observeAttendance(userId: String) async {
        do {
            for try await attendedIds in observeAttendedEventIds.execute(userId: userId) {
                uiState.isCheckedIn = uiState.isCheckedIn || attendedIds.contains(eventId)
            }
        } catch {
            return
        }
    }
}
