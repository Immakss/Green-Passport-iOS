protocol EventsRepository {
    func observeEvents() -> AsyncThrowingStream<[EcoEvent], Error>
    func observeRegisteredEventIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
    func observeAttendedEventIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
    func registerForEvent(userId: String, eventId: String) async throws
}
