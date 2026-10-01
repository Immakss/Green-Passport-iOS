final class ObserveAttendedEventIdsUseCase {
    private let eventsRepository: EventsRepository

    init(eventsRepository: EventsRepository) {
        self.eventsRepository = eventsRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return eventsRepository.observeAttendedEventIds(userId: userId)
    }
}
