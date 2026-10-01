import Foundation

final class ObserveUpcomingEventUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute() -> AsyncThrowingStream<EcoEvent?, Error> {
        return StreamCombiner.mapped(eventsRepository.observeEvents()) { events in
            let now = Date()
            return events
                .filter { return $0.startAt > now }
                .min { return $0.startAt < $1.startAt }
        }
    }
}
