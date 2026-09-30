import Foundation

final class FetchUpcomingEventUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute() async throws -> EcoEvent? {
        let now = Date()
        return try await eventsRepository.fetchEvents()
            .filter { return $0.startAt > now }
            .min { return $0.startAt < $1.startAt }
    }
}
