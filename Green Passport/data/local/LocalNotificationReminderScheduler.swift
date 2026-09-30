import Foundation
import UserNotifications

final class LocalNotificationReminderScheduler: ReminderScheduler {
    private static let identifierPrefix = "event_reminder_"

    private let settingsRepository: SettingsRepository
    private let notificationLogRepository: NotificationLogRepository
    private let notificationPermission: NotificationPermission
    private let center: UNUserNotificationCenter

    init(
        settingsRepository: SettingsRepository,
        notificationLogRepository: NotificationLogRepository,
        notificationPermission: NotificationPermission,
        center: UNUserNotificationCenter = .current()
    ) {
        self.settingsRepository = settingsRepository
        self.notificationLogRepository = notificationLogRepository
        self.notificationPermission = notificationPermission
        self.center = center
    }

    func scheduleEventReminder(eventId: String, title: String, at date: Date) async {
        let fireDate = max(date, Date())
        notificationLogRepository.log(title: String(localized: .eventReminderTitle), body: title, sentAt: fireDate)
        guard settingsRepository.isNotificationsEnabled, await notificationPermission.requestIfNeeded() else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(localized: .eventReminderTitle)
        content.body = title
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifierPrefix + eventId, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelEventReminder(eventId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifierPrefix + eventId])
    }
}
