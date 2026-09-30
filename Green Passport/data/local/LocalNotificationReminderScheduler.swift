import Foundation
import UserNotifications

final class LocalNotificationReminderScheduler: ReminderScheduler {
    private static let identifierPrefix = "event_reminder_"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func scheduleEventReminder(eventId: String, title: String, at date: Date) async {
        guard date > Date(), await isAuthorized() else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(localized: .eventReminderTitle)
        content.body = title
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifierPrefix + eventId, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelEventReminder(eventId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifierPrefix + eventId])
    }

    private func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ?? false
        default:
            return false
        }
    }
}
