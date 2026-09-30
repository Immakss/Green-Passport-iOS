protocol SettingsRepository {
    var isOnboardingSeen: Bool { get }
    var isNotificationsEnabled: Bool { get }
    func markOnboardingSeen()
    func setNotificationsEnabled(_ isEnabled: Bool)
}
