final class SetNotificationsEnabledUseCase {
    private let settingsRepository: SettingsRepository
    private let notificationPermission: NotificationPermission

    init(settingsRepository: SettingsRepository, notificationPermission: NotificationPermission) {
        self.settingsRepository = settingsRepository
        self.notificationPermission = notificationPermission
    }

    func execute(isEnabled: Bool) async -> Bool {
        guard isEnabled else {
            settingsRepository.setNotificationsEnabled(false)
            return false
        }
        let isGranted = await notificationPermission.requestIfNeeded()
        settingsRepository.setNotificationsEnabled(isGranted)
        return isGranted
    }
}
