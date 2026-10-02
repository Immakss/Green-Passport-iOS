final class ObserveEventsUseCase {
    private let eventsRepository: EventsRepository
    private let includesArchived: Bool

    init(eventsRepository: EventsRepository, includesArchived: Bool = false) {
        self.eventsRepository = eventsRepository
        self.includesArchived = includesArchived
    }

    func execute() -> AsyncThrowingStream<[EcoEvent], Error> {
        let includesArchived = includesArchived
        return StreamCombiner.mapped(eventsRepository.observeEvents()) { events in
            let visible = includesArchived ? events : events.filter { return $0.isActive }
            return visible.sorted { return $0.startAt < $1.startAt }
        }
    }
}
