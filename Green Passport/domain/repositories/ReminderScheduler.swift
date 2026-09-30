import Foundation

protocol ReminderScheduler {
    func scheduleEventReminder(eventId: String, title: String, at date: Date) async
    func cancelEventReminder(eventId: String)
}
