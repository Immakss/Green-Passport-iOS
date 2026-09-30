import UserNotifications

final class UserNotificationPermission: NotificationPermission {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestIfNeeded() async -> Bool {
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
