import Foundation

final class RegisterForEventUseCase {
    private static let reminderLeadTime: TimeInterval = 60 * 60

    private let eventsRepository: EventsRepository
    private let reminderScheduler: ReminderScheduler

    init(eventsRepository: EventsRepository, reminderScheduler: ReminderScheduler) {
        self.eventsRepository = eventsRepository
        self.reminderScheduler = reminderScheduler
    }

    func execute(userId: String, event: EcoEvent) async throws {
        try await eventsRepository.registerForEvent(userId: userId, eventId: event.id)
        await reminderScheduler.scheduleEventReminder(
            eventId: event.id,
            title: event.title,
            at: event.startAt.addingTimeInterval(-Self.reminderLeadTime)
        )
    }
}
