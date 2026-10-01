final class ObserveEventsUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute() -> AsyncThrowingStream<[EcoEvent], Error> {
        return StreamCombiner.mapped(eventsRepository.observeEvents()) { events in
            return events.sorted { return $0.startAt < $1.startAt }
        }
    }
}
