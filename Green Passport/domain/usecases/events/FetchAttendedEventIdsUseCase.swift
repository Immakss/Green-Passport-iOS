final class FetchAttendedEventIdsUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute(userId: String) async throws -> Set<String> {
        return try await eventsRepository.fetchAttendedEventIds(userId: userId)
    }
}
