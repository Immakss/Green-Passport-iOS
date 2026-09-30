protocol EventsRepository {
    func fetchEvents() async throws -> [EcoEvent]
    func fetchRegisteredEventIds(userId: String) async throws -> Set<String>
    func registerForEvent(userId: String, eventId: String) async throws
}
