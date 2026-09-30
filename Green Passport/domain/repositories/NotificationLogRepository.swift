import Foundation

protocol NotificationLogRepository {
    func log(title: String, body: String, sentAt: Date)
    func entries(before date: Date) -> [NotificationLogEntry]
}
