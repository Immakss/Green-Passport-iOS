final class SetNotificationsEnabledUseCase {
    private let settingsRepository: SettingsRepository
    private let notificationPermission: NotificationPermission
    private let reminderScheduler: ReminderScheduler

    init(settingsRepository: SettingsRepository, notificationPermission: NotificationPermission, reminderScheduler: ReminderScheduler) {
        self.settingsRepository = settingsRepository
        self.notificationPermission = notificationPermission
        self.reminderScheduler = reminderScheduler
    }

    func execute(isEnabled: Bool) async -> Bool {
        guard isEnabled else {
            settingsRepository.setNotificationsEnabled(false)
            reminderScheduler.cancelStreakReminder()
            return false
        }
        let isGranted = await notificationPermission.requestIfNeeded()
        settingsRepository.setNotificationsEnabled(isGranted)
        return isGranted
    }
}
