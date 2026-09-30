protocol SettingsRepository {
    var isOnboardingSeen: Bool { get }
    var isNotificationsEnabled: Bool { get }
    var theme: AppTheme { get }
    func markOnboardingSeen()
    func setNotificationsEnabled(_ isEnabled: Bool)
    func setTheme(_ theme: AppTheme)
}
