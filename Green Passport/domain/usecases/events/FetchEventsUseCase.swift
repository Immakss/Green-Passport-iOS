final class FetchEventsUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute() async throws -> [EcoEvent] {
        return try await eventsRepository.fetchEvents().sorted { $0.startAt < $1.startAt }
    }
}
